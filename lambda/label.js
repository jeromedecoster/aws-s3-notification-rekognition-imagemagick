const cp = require('child_process')
const fsp = require('fs').promises
const AWS = require('aws-sdk')
const util = require('util')
const path = require('path')

AWS.config.update({ region: 'eu-west-1' })

const exec = util.promisify(cp.exec)
const s3 = new AWS.S3({ apiVersion: '2006-03-01' })

exports.handler = async (event) => {
  let record = event.Records[0]

  let rand = Math.random().toString(32).substr(2)
  // filename without path and also without extension
  let basename = path.basename(record.s3.object.key, path.extname(record.s3.object.key))

  let data = {
    region: record.awsRegion,
    bucket: record.s3.bucket.name,
    key: record.s3.object.key,

    input: `/tmp/${rand}`,
    output: `/tmp/convert-${rand}`,
    converted: `converted/${basename}.jpg`
  }

  try {

    await getLabel(data)
    await getUpload(data)
    await compute(data)
    await draw(data)
    await putConverted(data)

    return {
      statusCode: 200,
      body: `https://${data.bucket}.s3.${data.region}.amazonaws.com/${data.converted}`,
    }

  } catch (err) {
    throw new Error(err)
  }
}

// get the label JSON object from S3
async function getLabel(data) {
  let label = await s3
    .getObject({
      Bucket: data.bucket,
      Key: data.key
    })
    .promise()

  var json = JSON.parse(label.Body)
  data.upload = json.Key

  // if bird, cat or dog previously found
  if (json.Instance != null) {
    data.name = json.Name
    data.instance = json.Instance
  }

  return Promise.resolve(data)
}

// get the uploaded image object from S3 and write it to /tmp
async function getUpload(data) {

  let upload = await s3
    .getObject({
      Bucket: data.bucket,
      Key: data.upload
    })
    .promise()

  return fsp.writeFile(data.input, upload.Body)
}

// compute data for the image
async function compute(data) {
  // get image width and height
  let size = await exec(`/opt/bin/identify -format '%w %h' ${data.input}`)
  let arr = size.stdout.split(' ')
  let iw = parseFloat(arr[0])
  let ih = parseFloat(arr[1])

  // imagemagick rectangle coords
  if (data.instance != null) {
    let left = Math.round(iw * data.instance.BoundingBox.Left)
    let top = Math.round(ih * data.instance.BoundingBox.Top)
    let width = left + Math.round(iw * data.instance.BoundingBox.Width)
    let height = top + Math.round(ih * data.instance.BoundingBox.Height)
    let outleft = left - 30
    let outtop = top - 30
    let outwidth = width + 30
    let outheight = height + 30

    // blue for bird
    let color = 'blue'
    if (data.name == 'Cat') color = 'red'
    else if (data.name == 'Dog') color = 'green'

    data.draw = {
      left,
      top,
      width,
      height,
      outleft,
      outtop,
      outwidth,
      outheight,
      color
    }
  }

  return Promise.resolve(data)
}

// draw the rectangle or convert to gray
async function draw(data) {
  let cmd = ''
  if (data.instance != null) {
    cmd = `/opt/bin/convert ${data.input} ` +
      `\\\( +clone -fill white -colorize 100 -fill ${data.draw.color} -draw "rectangle ${data.draw.outleft},${data.draw.outtop} ${data.draw.outwidth},${data.draw.outheight}" ` +
      `-fill white -draw "rectangle ${data.draw.left},${data.draw.top} ${data.draw.width},${data.draw.height}"  \\\) -compose multiply -composite ${data.output}`

  } else {
    cmd = `/opt/bin/convert ${data.input} -colorspace Gray ${data.output}`
  }

  return exec(cmd)
}

// put an object from /tmp to S3
async function putConverted(data) {
  let body = await fsp.readFile(data.output)

  return s3
    .putObject({
      Body: body,
      Bucket: data.bucket,
      Key: data.converted,
      ACL: 'public-read',
      ContentType: 'image/jpeg'
    })
    .promise()
}
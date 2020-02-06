const AWS = require('aws-sdk')
const path = require('path')

AWS.config.update({ region: 'eu-west-1' })

const rekognition = new AWS.Rekognition({ apiVersion: '2016-06-27' })
const s3 = new AWS.S3({ apiVersion: '2006-03-01' })

exports.handler = async (event) => {
  let record = event.Records[0]
  let key = record.s3.object.key
  let basename = path.basename(key, path.extname(key))

  let data = {
    region: record.awsRegion,
    bucket: record.s3.bucket.name,
    key,
    output: `labels/${basename}.json`,
  }

  try {

    await detectLabels(data)
    await parseLabels(data)
    await putObject(data)

    return {
      statusCode: 200,
      body: `https://${data.bucket}.s3.${data.region}.amazonaws.com/${data.output}`,
    }

  } catch (err) {
    throw new Error(err)
  }
}

// call rekognition to detect labels 
async function detectLabels(data) {

  let labels = await rekognition
    .detectLabels({
      Image: {
        S3Object: {
          Bucket: data.bucket,
          Name: data.key
        }
      }
    })
    .promise()

  data.labels = labels
  return Promise.resolve(data)
}

// is there bird, cat or dog ?
async function parseLabels(data) {

  let found = data.labels.Labels
    .find(e => e.Name == 'Bird' || e.Name == 'Cat' || e.Name == 'Dog')

  if (found != null && found.Instances.length > 0) {
    data.name = found.Name
    data.instance = found.Instances[0]
  }
  return Promise.resolve(data)
}

// write JSON to /labels
async function putObject(data) {
  var body = {
    Labels: data.labels.Labels,
    Key: data.key
  }

  // if bird, cat or dog found
  if (data.instance != null) {
    body.Name = data.name
    body.Instance = data.instance
  }

  return s3
    .putObject({
      Body: JSON.stringify(body, null, 2),
      Bucket: data.bucket,
      Key: data.output,
      ContentType: 'application/json'
    })
    .promise()
}
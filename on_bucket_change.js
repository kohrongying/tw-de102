const AWS = require('aws-sdk');

const sns = new AWS.SNS()

exports.handler = (event, context, callback) => {
    // This reads the environment variable 'sns_topic_arn'
    var topic_arn = process.env.sns_topic_arn
    var publishParams = {
        TopicArn: topic_arn,
        Message: JSON.stringify(event, null, 2)
    };
    sns.publish(publishParams, (err, data) => {
        if (err) console.log(err)
        else callback(null, "Completed");
    })
};
import boto3
import os
import json

sns = boto3.client('sns')
topic_arn = os.environ.get('TOPIC_ARN')
def publish_message(subject, body):
    topicArn = topic_arn
    try:
        sns.publish(TopicArn=topicArn, Message=body, Subject=subject)
    except:
        print(f'Failed to send message to {topicArn}')
 


def lambda_handler(event, context):
    message = None
    if event['Records'][0]['Sns']['Message'] == None:
        return "No message found."
    else:
        message = event['Records'][0]['Sns']['Message']
    
    try:
        
        parse_message = json.loads(message)
    except:
        parse_message = None
        print("No valuable records found.")
    
    return message

#lambda_handler(event, None)
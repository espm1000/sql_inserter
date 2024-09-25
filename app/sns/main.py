import boto3

class SnsWrapper:
    
    def __init__(self, sns_resource):
        self.sns_resource = sns_resource

    def list_topics(self):

        try:
            topics = self.sns_resource.topics.all()
        except:
            return "uh oh"
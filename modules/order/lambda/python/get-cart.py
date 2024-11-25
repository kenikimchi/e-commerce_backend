import json
import boto3
import boto3.dynamodb
from botocore.exceptions import ClientError

# Initialize client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('guest_cart')

def lambda_handler(event, context):
    cart_id = event.get('queryStringParameters', {}).get('cart_id')

    if not cart_id:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'No cartId'})
        }
    
    try:
        response = table.query(
            keyConditionExpression=boto3.dynamodb.conditions.Key('cart_id').eq(cart_id)
        )
        items = response.get('Items', [])
        
        # Create cart if no cart found
        if not items:
            new_cart = {
                'cart_id': cart_id,
                'items': []
            }
            table.put_item(Item=new_cart)
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'New cart created', 'cart': new_cart})
            }

        return {
            'statusCode': 200,
            'body': json.dumps({'cart_id': cart_id, 'items': items})
        }
    
    except ClientError as err:
        print(f'DynamoDB query error: {err}')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to get cart items'})
        }
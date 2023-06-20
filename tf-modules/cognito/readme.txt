Please note that you need to replace <API_GATEWAY_ID> with the actual ID of your API Gateway resource.
Also, make sure to update other values like the AWS region, Cognito User Pool name, and user group names according to your requirements.

This configuration creates a Cognito User Pool with two user groups: AdminUser and StandardUser.
It also creates IAM policies and roles for granting permissions to access API endpoints.
The access restrictions are defined using IAM policies, and the API Gateway methods are restricted based on the Cognito user groups.
# Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_name
}

# API url path
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "users"  # Replace with the desired resource path: https://2hmnj999ic.execute-api.us-west-1.amazonaws.com/stage-01/users
}

# Define at least one method in the API Gateway REST API before creating the deployment
resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS" // "COGNITO_USER_POOLS" in authorizer
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

# Integration for the method in the API Gateway resource
resource "aws_api_gateway_integration" "api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api_resource.id
  http_method             = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn

}

# Create an API Gateway deploymen
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on    = [aws_api_gateway_integration.api_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  #stage_name  = var.stage_name //  (Optional) Name of the stage to create with this deployment.
}

# # Name of the stage to create with this deployment.
resource "aws_api_gateway_stage" "stage_name" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name               = "authorizer-01-lambda"
  rest_api_id        = aws_api_gateway_rest_api.api.id
  #authorizer_uri         = aws_lambda_function.lambda_function.invoke_arn
  #authorizer_credentials = aws_iam_role.lambda_function_role.arn
  identity_source    = "method.request.header.Authorization"
  type               = "COGNITO_USER_POOLS"
  provider_arns      = [aws_cognito_user_pool.user_pool.arn]
}







# Error: creating API Gateway Deployment: BadRequestException: No integration defined for method




# # Create the API Gateway REST API
# resource "aws_api_gateway_rest_api" "api" {
#   name        = var.api_name
#   description = var.api_name
# }

# # API url path
# resource "aws_api_gateway_resource" "api_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "users"  # Resource path: https://2hmnj999ic.execute-api.us-west-1.amazonaws.com/stage-01/users
# }

# # Define at least one method in the API Gateway REST API before creating the deployment
# resource "aws_api_gateway_method" "api_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.api_resource.id
#   http_method   = "OPTIONS"
#   authorization = "COGNITO_USER_POOLS" // "COGNITO_USER_POOLS" in authorizer
#   authorizer_id = aws_api_gateway_authorizer.authorizer.id
# }

# #cors
# resource "aws_api_gateway_method_response" "api_response" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.api_resource.id
#   http_method = aws_api_gateway_method.api_method.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }

#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true,
#     "method.response.header.Access-Control-Allow-Methods" = true,
#     "method.response.header.Access-Control-Allow-Origin" = true
#   }

#   depends_on = [aws_api_gateway_method.api_method]
  
# }

# # Integration for the method in the API Gateway resource
# resource "aws_api_gateway_integration" "api_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.api_resource.id
#   http_method             = aws_api_gateway_method.api_method.http_method
#   #integration_http_method = "GET"
#   #type                    = "AWS_PROXY"
#   type                    = "MOCK"
#   #uri                     = aws_lambda_function.lambda_function.invoke_arn

#   depends_on = [aws_api_gateway_method.api_method]

#   request_parameters = {
#     "integration.request.header.X-Authorization" = "'static'"
#   }

#   # Transforms the incoming XML request to JSON
#   request_templates = {
#     "application/xml" = <<EOF
# {
#    "body" : $input.json('$')
# }
# EOF
#   }
# }


# #cors
# resource "aws_api_gateway_integration_response" "users_integration_response" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.api_resource.id
#   http_method = aws_api_gateway_method.cors_method.http_method
#   status_code = aws_api_gateway_method_response.cors_method_response_200.status_code
  
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
#     "method.response.header.Access-Control-Allow-Methods" = "GET,OPTIONS,POST,PUT",
#     "method.response.header.Access-Control-Allow-Origin" = "*"
#   }

#   depends_on = [aws_api_gateway_method_response.api_response]
# }

# resource "aws_api_gateway_method" "cors_method" {
#     rest_api_id   = aws_api_gateway_rest_api.api.id
#     resource_id   = aws_api_gateway_resource.api_resource.id
#     http_method   = "POST"
#     authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "cors_method_response_200" {
#     rest_api_id = aws_api_gateway_rest_api.api.id
#     resource_id = aws_api_gateway_resource.api_resource.id
#     http_method = aws_api_gateway_method.cors_method.http_method
#     status_code = "200"
#     response_parameters = {
#         "method.response.header.Access-Control-Allow-Origin" = true
#     }
#     depends_on = [aws_api_gateway_method.cors_method]
# }

# resource "aws_api_gateway_integration" "integration" {
#     rest_api_id = aws_api_gateway_rest_api.api.id
#     resource_id = aws_api_gateway_resource.api_resource.id
#     http_method = aws_api_gateway_method.api_method.http_method
#     integration_http_method = "POST"
#     type          = "AWS_PROXY"
#     uri           = aws_lambda_function.lambda_function.invoke_arn
#     depends_on    = [aws_api_gateway_method.cors_method, aws_lambda_function.lambda_function]
# }

# # Create an API Gateway deploymen
# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on    = [aws_api_gateway_integration.integration]
#                   # aws_api_gateway_integration.api_integration,
#                   # aws_api_gateway_method.api_method,
#                   # aws_api_gateway_method.cors_method
                  
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = var.stage_name //  (Optional) use resource "aws_api_gateway_stage" 
# }

# # Name of the stage to create with this deployment.
# resource "aws_api_gateway_stage" "stage_name" {
#   deployment_id = aws_api_gateway_deployment.api_deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   stage_name  = var.stage_name
# }

# resource "aws_api_gateway_authorizer" "authorizer" {
#   name               = "authorizer-01-lambda"
#   rest_api_id        = aws_api_gateway_rest_api.api.id
#   #authorizer_uri         = aws_lambda_function.lambda_function.invoke_arn
#   #authorizer_credentials = aws_iam_role.lambda_function_role.arn
#   identity_source    = "method.request.header.Authorization"
#   type               = "COGNITO_USER_POOLS"
#   provider_arns      = [aws_cognito_user_pool.user_pool.arn]
# }


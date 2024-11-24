#create lambda function in node js  named group1Function1

resource "aws_lambda_function" "group2Function1" {
  function_name    = "group2Function1"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.group2Function1Role.arn
  filename         = "group2Function1.zip"
  source_code_hash = filebase64sha256("group2Function1.zip")
}

# create lambda function in node js  named group1Function2

resource "aws_lambda_function" "group2Function2" {
  function_name    = "group2Function2"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  role             = aws_iam_role.group2Function2Role.arn
  filename         = "group2Function2.zip"
  source_code_hash = filebase64sha256("group2Function2.zip")
}

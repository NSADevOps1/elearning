#Create SNS Topics
resource "aws_sns_topic" "e-learning-sns" {
  name = var.e-learning-sns
}


resource "aws_sns_topic_subscription" "e-learning-sqs-target" {
  topic_arn = aws_sns_topic.e-learning-sns.arn
  endpoint  = "nikkimansoh@gmail.com"
  protocol  = "email"
}


resource "aws_sns_topic_policy" "sns-policy" {
  arn = aws_sns_topic.e-learning-sns.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.e-learning-sns.arn
      }
    ]
  })
}


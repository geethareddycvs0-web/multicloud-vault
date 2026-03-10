# IAM role for cross-cloud service account
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.project}-${var.environment}-app-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

# S3 access policy
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [var.s3_bucket_arn, "${var.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "${var.project}-${var.environment}-s3-access"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project}-${var.environment}-profile"
  role = aws_iam_role.app.name
}

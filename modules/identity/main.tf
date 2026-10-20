
# ==========================================
# IDENTIDAD DE LA CUENTA AWS
# ==========================================

data "aws_caller_identity" "current" {}


# ==========================================
# 1. ROL DE EJECUCION DE DATOS
# ==========================================

resource "aws_iam_role" "data_execution" {
  name = "coderhouse-${var.environment}-data-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "coderhouse-${var.environment}-data-execution-role"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}


# ==========================================
# 2. POLITICA DE ACCESO A S3
# ==========================================

resource "aws_iam_role_policy" "data_s3_access" {
  name = "coderhouse-${var.environment}-data-s3-access"
  role = aws_iam_role.data_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListDataPrefix"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::${var.data_bucket_name}"

        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.data_prefix}*"
            ]
          }
        }
      },
      {
        Sid    = "ReadWriteDataObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "arn:aws:s3:::${var.data_bucket_name}/${var.data_prefix}*"
      }
    ]
  })
}


# ==========================================
# 3. ROL DE AUDITORIA
# ==========================================

resource "aws_iam_role" "audit" {
  name = "coderhouse-${var.environment}-audit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/coder-terraform"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "coderhouse-${var.environment}-audit-role"
    Environment = var.environment
    Project     = "coderhouse-data-engineering"
  }
}


# ==========================================
# 4. POLITICA DE AUDITORIA
# ==========================================

resource "aws_iam_role_policy" "audit_readonly" {
  name = "coderhouse-${var.environment}-audit-readonly"
  role = aws_iam_role.audit.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadNetworkConfiguration"
        Effect = "Allow"

        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeAvailabilityZones"
        ]

        Resource = "*"
      },
      {
        Sid    = "ReadProjectRoles"
        Effect = "Allow"

        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListRoleTags"
        ]

        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/coderhouse-*"
      },
      {
        Sid    = "ReadStateBucketConfiguration"
        Effect = "Allow"

        Action = [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock"
        ]

        Resource = "arn:aws:s3:::coderhouse-tfstate-*"
      }
    ]
  })
}

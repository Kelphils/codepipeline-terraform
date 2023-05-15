data "aws_caller_identity" "default" {}

#EC2 Code deploy service role
resource "aws_iam_role" "ec2codedeploy_role" {
  name = "${var.project}_ec2_codedeploy_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Service = "${var.project}-role-${var.environment}"
  }

}

resource "aws_iam_role_policy_attachment" "AnazonEc2RoleforAWSCodeDeploy_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ec2_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_fullaccess_attach" {
  role       = aws_iam_role.ec2codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_code_deploy_instance_profile" {
  name = "${var.project}_code_deploy_instance_profile"
  role = aws_iam_role.ec2codedeploy_role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#AWS Code Deploy Service Role
resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.project}_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Service = "${var.project}-role-${var.environment}"
  }

}

resource "aws_iam_role_policy_attachment" "codedeploy_attachment_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role_policy_attachment" "codedeploy_s3_fullaccess_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


#EC2 service role for cloud watch agent
resource "aws_iam_role" "ec2_cw_agent_ssm_full_role" {
  name = "${var.project}_ec2_cw_agent_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Service = "${var.project}-role-${var.environment}"
  }

}


resource "aws_iam_role_policy_attachment" "CW_Agent_attach" {
  role       = aws_iam_role.ec2_cw_agent_ssm_full_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "asg_ec2_s3_fullaccess_attach" {
  role       = aws_iam_role.ec2_cw_agent_ssm_full_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "ssm_fullaccess_attach" {
  role       = aws_iam_role.ec2_cw_agent_ssm_full_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}_cw_agent_instance_profile"
  role = aws_iam_role.ec2_cw_agent_ssm_full_role.name
}

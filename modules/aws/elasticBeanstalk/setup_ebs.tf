

// CREATING INSTANCE PROFILE


data "aws_iam_policy_document" "profile" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.application.name}-ec2-role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.profile.json
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.application.name}-ec2-profile"
  role = "${aws_iam_role.ec2.name}"
}
// Attaching all policy to the ec2 profile
resource "aws_iam_role_policy_attachment" "elastic_beanstalk_multi_container_docker" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}
resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "ssm_ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"

  lifecycle {
    create_before_destroy = true
  }
}



// CREATING SERVICE PROFILE
data "aws_iam_policy_document" "service" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }

    effect = "Allow"
  }
}
resource "aws_iam_role" "service" {
  name               = "${var.application.name}-eb-service"
  assume_role_policy = data.aws_iam_policy_document.service.json
}

resource "aws_iam_role_policy_attachment" "enhanced_health" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_elastic_beanstalk_application" "application" {
  name        = "${var.application.name}"
  description = "${var.application.description}"
}

resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "${var.environment.name}"
  application         = "${aws_elastic_beanstalk_application.application.name}"
  solution_stack_name = "${var.environment.solution_stack_name}"
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.instance_profile.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.service.name
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }
}

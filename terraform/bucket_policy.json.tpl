{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "public_read",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${bucket}/*"
    }
  ]
}
import { Stack, StackProps, CfnOutput } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Bucket, CfnBucket } from 'aws-cdk-lib/aws-s3';
import { CfnParameter, Duration } from 'aws-cdk-lib/core';

class L3Bucket extends Construct {
  constructor(scope: Construct, id: string, expiration: number) {
    super(scope, id);
    new Bucket(this, 'nemo-l3-dev', {
      lifecycleRules: [
        {
          expiration: Duration.days(expiration),
        },
      ],
    });
  }
}

export class NemoWebStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
    new CfnBucket(this, 'nemo-l1-dev', {
      lifecycleConfiguration: {
        rules: [
          {
            expirationInDays: 1,
            status: 'Enabled',
          },
        ],
      },
    });
    const duration = new CfnParameter(this, 'duration', {
      default: 6,
      minValue: 1,
      maxValue: 10,
      type: 'Number',
    });
    const l2bucket = new Bucket(this, 'nemo-l2-dev', {
      lifecycleRules: [
        {
          expiration: Duration.days(duration.valueAsNumber),
        },
      ],
    });
    new CfnOutput(this, 'nemo-l2-dev-output', {
      value: l2bucket.bucketName,
    });
    new L3Bucket(this, 'nemo-l3-dev', 3);
  }
}

import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class UtopiaStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    new cdk.aws_ecs_patterns.ApplicationLoadBalancedFargateService(
      this,
      'UtopiaService',
      {
        taskImageOptions: {
          image: cdk.aws_ecs.ContainerImage.fromRegistry(
            'amazon/amazon-ecs-sample'
          ),
        },
        publicLoadBalancer: true,
      }
    );
  }
}

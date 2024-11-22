import { Stack, StackProps } from 'aws-cdk-lib';
import { ContainerImage } from 'aws-cdk-lib/aws-ecs';
import { ApplicationLoadBalancedFargateService } from 'aws-cdk-lib/aws-ecs-patterns';
import { Construct } from 'constructs';
// import { S3Bucket } from './constructs/S3Bucket';

export class NemoWebStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    new ApplicationLoadBalancedFargateService(this, 'MyWebServer', {
      taskImageOptions: {
        image: ContainerImage.fromRegistry('amazon/amazon-ecs-sample'),
      },
      publicLoadBalancer: true,
    });

    // const bucket = new S3Bucket(this, 'MyRemovableBucket', {
    //   environment: 'dev',
    // });

    // add a lambda function that works with docker image
    // const lambda = new DockerImageFunction(this, 'MyFunction', {
    //   code: DockerImageCode.fromImageAsset(path.join(__dirname, '../lambda')),
    //   environment: {
    //     BUCKET_NAME: bucket.bucketName,
    //   },
    // });

    // bucket.grantReadWrite(lambda);
  }
}

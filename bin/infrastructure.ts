#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { UtopiaWebStack } from '../lib';

const app = new cdk.App();
new UtopiaWebStack(app, 'UtopiaWebStack', {
  description: 'Utopia Web Stack',
});

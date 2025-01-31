#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { NemoWebStack } from '../lib';

const app = new cdk.App();
new NemoWebStack(app, 'NemoWebStack', {
  description: 'Nemo Web Stack',
});

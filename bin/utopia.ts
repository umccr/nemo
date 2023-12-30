#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { UtopiaStack } from '../lib/utopia-stack';

const app = new cdk.App();
new UtopiaStack(app, 'UtopiaStack', {
  description: 'Utopia Stack',
});

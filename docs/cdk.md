# AWS CDK

## Notes

- **App**: application written in e.g. TypeScript that defines one or more
  **Stacks**.
- **Stack**: a logical grouping of **Constructs**.
- **Construct**: a logical grouping of **Resources**.
- **Resource**: e.g. S3 buckets, Lambda, DynamoDB.

A construct class takes three params:

- **scope**: use `this` to say the stack is its parent.
- **id**: logical ID of construct within app.
- **props**: bundle of key-values passed in an object.

## Commands

| Command                  | Description                       |
| ------------------------ | --------------------------------- |
| `cdk init -l typescript` | initialize cdk project            |
| `npm run build`          | compile ts to js                  |
| `npm run watch`          | watch for changes and compile     |
| `npm run test`           | run jest unit tests               |
| `npx cdk deploy`         | deploy stack                      |
| `npx cdk diff`           | compare current to deployed stack |
| `npx cdk synth`          | emit synthesized cfn template     |
| `npx cdk destroy`        | destroy stack                     |
| `npx cdk bootstrap`      | bootstrap cdk project             |

import { Flow } from '@pgflow/dsl';

type Input = {
  firstName: string;
  lastName: string;
};

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
const randomSleep = (min: number, max: number) =>
  sleep(Math.floor(Math.random() * (max - min + 1)) + min);

export const GreetUser = new Flow<Input>({
  slug: 'greetUser',
})
  .step({ slug: 'fullName' }, async ({ run }) => {
    await randomSleep(50, 150); // Simulate fast API call
    return `${run.firstName} ${run.lastName}`;
  })
  .step({ slug: 'greeting', dependsOn: ['fullName'] }, async (deps) => {
    await randomSleep(50, 150); // Simulate fast API call
    return `Hello, ${deps.fullName}!`;
  });

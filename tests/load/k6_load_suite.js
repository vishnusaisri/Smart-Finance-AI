import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 300 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const BASE_URL = __ENV.TARGET_HOST || 'http://localhost:49390';

  // Scenario 1: Dashboard Navigation
  let res1 = http.get(`${BASE_URL}/#/dashboard`);
  check(res1, { 'status is 200': (r) => r.status === 200 });

  sleep(1);

  // Scenario 2: Expenses View
  let res2 = http.get(`${BASE_URL}/#/expenses`);
  check(res2, { 'status is 200': (r) => r.status === 200 });

  sleep(1);

  // Scenario 3: Budgets View
  let res3 = http.get(`${BASE_URL}/#/budgets`);
  check(res3, { 'status is 200': (r) => r.status === 200 });

  sleep(1);
}

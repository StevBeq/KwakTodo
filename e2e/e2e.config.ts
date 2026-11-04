import type { E2EConfig } from 'e2e';
import { mobile } from '@e2e-dev/mobile';
import { gateway } from 'ai';

// Application ID dari android/app/build.gradle.kts
const app = { bundleId: 'com.example.todo_list' };

export default {
  agents: {
    default: {
      model: gateway('google/gemini-2.5-flash'),
      system: 'Kamu adalah agen QA testing berpengalaman. Jalankan pengujian aplikasi Smart Todo dan pastikan hasil sesuai spesifikasi.',
    },
  },
  targets: [
    { name: 'android', engine: mobile({ platform: 'android' }), app },
    { name: 'ios', engine: mobile({ platform: 'ios' }), app },
  ],
  workers: 1,
} satisfies E2EConfig;


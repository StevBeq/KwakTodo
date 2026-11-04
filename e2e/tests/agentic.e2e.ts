import { test } from '@e2e-dev/mobile';
import { expect } from 'e2e';

const skip = process.env.AI_GATEWAY_API_KEY
  ? false
  : 'Atur AI_GATEWAY_API_KEY untuk menjalankan pengujian agentic AI';

test('AI agent membuat tugas baru secara otomatis', { skip }, async ({ app, agent, screen }) => {
  await app.open();

  // Agent mengarahkan aksi untuk menambah tugas
  await agent.act('tambahkan tugas baru berjudul "Siapkan Presentasi Tim"');

  // Assert via locator & via agent
  await expect(screen.getByText('Siapkan Presentasi Tim')).toBeVisible();
  await agent.assert('tugas Siapkan Presentasi Tim berhasil tampil di daftar tugas');
});

test('AI agent memeriksa statistik progres tugas', { skip }, async ({ app, agent, screen }) => {
  await app.open();

  // Agent berpindah ke layar statistik
  await agent.act('buka tab Statistik dan periksa progres tugas');

  await expect(screen.getByText('Progres Selesai')).toBeVisible();
  await agent.assert('layar statistik menampilkan ring progres selesai dan kartu total tugas');
});


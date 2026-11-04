import { test } from '@e2e-dev/mobile';
import { expect } from 'e2e';

test('menampilkan beranda dan navigasi utama', async ({ app, screen }) => {
  await app.open();

  // Verifikasi tombol tambah manual dan navigasi bawah
  await expect(screen.getByTestId('header_add_task_btn')).toBeVisible();
  await expect(screen.getByTestId('fab_ask_ai')).toBeVisible();
  await expect(screen.getByTestId('nav_beranda')).toBeVisible();
  await expect(screen.getByTestId('nav_jadwal')).toBeVisible();
  await expect(screen.getByTestId('nav_statistik')).toBeVisible();
  await expect(screen.getByTestId('nav_setelan')).toBeVisible();
});

test('tambah tugas manual dan muncul di tab Semua & Hari Ini', async ({ app, screen }) => {
  await app.open();

  // Buka form tambah manual via header
  await screen.getByTestId('header_add_task_btn').tap();

  // Isi judul tugas
  await screen.getByTestId('task_title_input').fill('Belajar E2E Testing');
  await screen.getByTestId('task_notes_input').fill('Menjalankan pengujian otomatis');

  // Submit form
  await screen.getByTestId('task_submit_btn').tap();

  // Verifikasi tugas muncul di list
  await expect(screen.getByText('Belajar E2E Testing')).toBeVisible();
});

test('filter tab mengubah daftar tugas', async ({ app, screen }) => {
  await app.open();

  // Filter ke tab Hari Ini
  await screen.getByTestId('tab_today').tap();

  // Filter ke tab Selesai
  await screen.getByTestId('tab_done').tap();

  // Kembali ke tab Semua
  await screen.getByTestId('tab_all').tap();
});

test('pindah antar layar di bottom navigation', async ({ app, screen }) => {
  await app.open();

  // Pindah ke Jadwal
  await screen.getByTestId('nav_jadwal').tap();
  await expect(screen.getByText('Jadwal')).toBeVisible();

  // Pindah ke Statistik
  await screen.getByTestId('nav_statistik').tap();
  await expect(screen.getByText('Statistik')).toBeVisible();

  // Pindah ke Setelan
  await screen.getByTestId('nav_setelan').tap();
  await expect(screen.getByText('Pengaturan')).toBeVisible();

  // Kembali ke Beranda
  await screen.getByTestId('nav_beranda').tap();
  await expect(screen.getByTestId('header_add_task_btn')).toBeVisible();
});


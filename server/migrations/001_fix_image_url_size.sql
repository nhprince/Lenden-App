-- Migration to increase image_url column size limits
-- Date: 2026-01-24
-- Description: Fixes "Data too long" error for base64 images by changing TEXT (64KB) to LONGTEXT (4GB)

ALTER TABLE products MODIFY image_url LONGTEXT;

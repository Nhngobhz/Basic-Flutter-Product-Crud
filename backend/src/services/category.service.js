const pool = require('../config/db');

exports.getCategories = async (search = '') => {
  const [rows] = await pool.execute(
    `SELECT * FROM categories WHERE name LIKE ? ORDER BY name`,
    [`%${search}%`]
  );
  return rows;
};

exports.createCategory = async (data) => {
  const { name, description } = data;
  await pool.execute(
    `INSERT INTO categories (name, description) VALUES (?, ?)`,
    [name, description ?? null]
  );
  return { message: "Category created" };
};

exports.updateCategory = async (id, data) => {
  const { name, description } = data;
  await pool.execute(
    `UPDATE categories SET name = ?, description = ? WHERE id = ?`,
    [name, description ?? null, id]
  );
  return { message: "Category updated" };
};

exports.getCategoryById = async (id) => {
  const [rows] = await pool.execute(
    `SELECT * FROM categories WHERE id = ?`,
    [id]
  );
  return rows[0] || null;
};


exports.deleteCategory = async (id) => {
  await pool.execute(
    `DELETE FROM categories WHERE id = ?`,
    [id]
  );
  return { message: "Category deleted" };
};
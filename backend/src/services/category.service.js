const pool = require('../config/db');

exports.getCategories = async (search = '') => {
  const [rows] = await pool.execute(
    `SELECT * FROM categories
     WHERE name LIKE ?
     ORDER BY name`,
    [`%${search}%`]
  );

  return rows;
};

exports.getCategoryById = async (id) => {
  const [rows] = await pool.execute(
    `SELECT * FROM categories WHERE id = ?`,
    [id]
  );
  return rows[0] || null;
};

exports.createCategory = async (data) => {
  const { name } = data;
  await pool.execute(
    `INSERT INTO categories (name) VALUES (?)`,
    [name]
  );
  return { message: "Category created" };
};

exports.updateCategory = async (id, data) => {
  const { name } = data;
  await pool.execute(
    `UPDATE categories SET name = ? WHERE id = ?`,
    [name, id]
  );
  return { message: "Category updated" };
};

exports.deleteCategory = async (id) => {
  await pool.execute(
    `DELETE FROM categories WHERE id = ?`,
    [id]
  );
  return { message: "Category deleted" };
};
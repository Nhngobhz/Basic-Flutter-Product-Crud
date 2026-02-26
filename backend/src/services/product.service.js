const pool = require('../config/db');

exports.getProducts = async (page = 1, limit = 20, search = '', sortBy = 'name') => {
  const safePage = Math.max(1, parseInt(page) || 1);
  const safeLimit = Math.max(1, parseInt(limit) || 20);
  const offset = (safePage - 1) * safeLimit;
  const safeSearch = typeof search === 'string' ? search : '';

  let orderBy = 'name ASC';

switch (sortBy) {
  case 'price_asc':
    orderBy = 'price ASC';
    break;
  case 'price_desc':
    orderBy = 'price DESC';
    break;
  case 'name':
  default:
    orderBy = 'name ASC';
}

  let sql = `SELECT * FROM products`;
  const params = [];

  if (safeSearch) {
    sql += `\n     WHERE name LIKE ?`;
    params.push(`%${safeSearch}%`);
  }

  sql += `\n     ORDER BY ${orderBy}`;
  sql += `\n     LIMIT ${safeLimit} OFFSET ${offset}`;

  const [rows] = await pool.execute(sql, params);

  return rows;
};

exports.getProductById = async (id) => {
  const [rows] = await pool.execute(
    `SELECT * FROM products WHERE id = ?`,
    [id]
  );
  return rows[0] || null;
};

exports.createProduct = async (data) => {
  const { name, description, category_id, price, image_url } = data;

  await pool.execute(
    `INSERT INTO products
     (name, description, category_id, price, image_url)
     VALUES (?, ?, ?, ?, ?)`,
    [
      name,
      description ?? null,
      category_id ?? null,
      price ?? null,
      image_url ?? null
    ]
  );

  return { message: "Product created" };
};

exports.updateProduct = async (id, data) => {
  const { name, description, category_id, price, image_url } = data;

  await pool.execute(
    `UPDATE products
     SET name = ?,
         description = ?,
         category_id = ?,
         price = ?,
         image_url = ?
     WHERE id = ?`,
    [
      name,
      description ?? null,  // 🔥 important
      category_id ?? null,
      price ?? null,
      image_url ?? null,
      id
    ]
  );

  return { message: "Product updated" };
};

exports.deleteProduct = async (id) => {
  await pool.execute(
    `DELETE FROM products WHERE id = ?`,
    [id]
  );

  return { message: "Product deleted" };
};

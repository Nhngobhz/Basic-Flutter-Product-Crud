const productService = require('../services/product.service');
const { validateRequired } = require('../utils/validator');
const fs = require('fs');
const path = require('path');
const service = require('../services/product.service');

exports.getAll = async (req, res, next) => {
  try {
    const { page, limit, search, sort_by } = req.query;

    // normalize/validate query parameters before sending to service
    const pageNum = Number.isNaN(Number(page)) ? 1 : Number(page);
    const limitNum = Number.isNaN(Number(limit)) ? 20 : Number(limit);
    const searchTerm = typeof search === 'string' ? search : '';
    const sortByTerm = sort_by === 'price' ? 'price' : 'name';

    const data = await productService.getProducts(
      pageNum,
      limitNum,
      searchTerm,
      sortByTerm
    );

    res.json(data);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const product = await productService.getProductById(req.params.id);
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res) => {
  try {
    const { name, description, category_id, price } = req.body;

    const image_url = req.file
      ? `/uploads/images/${req.file.filename}`
      : null;

    await service.createProduct({
      name,
      description,
      category_id,
      price,
      image_url
    });

    res.json({ message: "Product created" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;

    const existingProduct = await service.getProductById(id);

    if (!existingProduct) {
      return res.status(404).json({ message: "Product not found" });
    }

    // Delete image file
    if (existingProduct.image_url) {
      const imagePath = path.join(
        __dirname,
        '..',
        existingProduct.image_url
      );

      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    await service.deleteProduct(id);

    res.json({ message: "Product deleted" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, category_id, price } = req.body;

    const existingProduct = await service.getProductById(id);

    if (!existingProduct) {
      return res.status(404).json({ message: "Product not found" });
    }

    let image_url = existingProduct.image_url;

    // If new image uploaded
    if (req.file) {

      // Delete old image if exists
      if (existingProduct.image_url) {
        const oldPath = path.join(
          __dirname,
          '..',
          existingProduct.image_url
        );

        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }

      image_url = `/uploads/images/${req.file.filename}`;
    }

    await service.updateProduct(id, {
      name,
      description,
      category_id,
      price,
      image_url
    });

    res.json({ message: "Product updated" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
const categoryService = require('../services/category.service');
const { validateRequired } = require('../utils/validator');

exports.getAll = async (req, res, next) => {
  try {
    const { search } = req.query;
    const data = await categoryService.getCategories(search);
    res.json(data);
  } catch (err) {
    next(err);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const category = await categoryService.getCategoryById(req.params.id);
    if (!category) return res.status(404).json({ message: "Category not found" });
    res.json(category);
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const error = validateRequired(req.body);
    if (error) return res.status(400).json({ message: error });

    const result = await categoryService.createCategory(req.body);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.update = async (req, res, next) => {
  try {
    const error = validateRequired(req.body);
    if (error) return res.status(400).json({ message: error });

    const result = await categoryService.updateCategory(req.params.id, req.body);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

exports.delete = async (req, res, next) => {
  try {
    const result = await categoryService.deleteCategory(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
};

const router = require('express').Router();
const controller = require('../controllers/category.controller');
const auth = require('../middlewares/auth.middleware');

// CRUD for categories
router.get('/', auth, controller.getAll);
router.get('/:id', auth, controller.getById);
router.post('/', auth, controller.create);
router.put('/:id', auth, controller.update);
router.delete('/:id', auth, controller.delete);

module.exports = router;
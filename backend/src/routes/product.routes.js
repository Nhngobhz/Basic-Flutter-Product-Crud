const router = require('express').Router();
const controller = require('../controllers/product.controller');
const authMiddleware = require('../middlewares/auth.middleware');
const upload = require('../middlewares/upload.middleware');

// CRUD for products
router.get('/', authMiddleware, controller.getAll);
router.get('/:id', authMiddleware, controller.getById);

router.post(
  '/',
  authMiddleware,
  upload.single('image'),
  controller.create
);
router.put(
  '/:id',
  authMiddleware,
  upload.single('image'),
  controller.update
);
router.delete('/:id', authMiddleware, controller.delete);

module.exports = router;
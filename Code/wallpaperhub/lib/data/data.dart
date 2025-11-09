import 'package:wallpaperhub/model/categories_model.dart';

List<CategoriesModel> getCategories() {
  List<CategoriesModel> categories = [];
  CategoriesModel categoriesModel = CategoriesModel();

  // Street Art
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/545008/pexels-photo-545008.jpeg";
  categoriesModel.categoryName = "Street Art";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // Wild Life
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/704320/pexels-photo-704320.jpeg";
  categoriesModel.categoryName = "Wild Life";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // Nature
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/34950/pexels-photo.jpg";
  categoriesModel.categoryName = "Nature";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // City
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/466685/pexels-photo-466685.jpeg";
  categoriesModel.categoryName = "City";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // Motivation
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/1434819/pexels-photo-1434819.jpeg";
  categoriesModel.categoryName = "Motivation";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // Bikes
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/2116475/pexels-photo-2116475.jpeg";
  categoriesModel.categoryName = "Bikes";
  categories.add(categoriesModel);
  categoriesModel = CategoriesModel();

  // Cars
  categoriesModel.imgUrl = 
    "https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg";
  categoriesModel.categoryName = "Cars";
  categories.add(categoriesModel);

  return categories;
}

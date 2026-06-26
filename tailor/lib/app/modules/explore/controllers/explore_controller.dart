import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/tailor_model.dart';
import '../../../data/providers/tailor_provider.dart';

class ExploreController extends GetxController {
  final tailors = <TailorModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = ''.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();

  Worker? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadTailors();
    _searchDebounce = debounce(
      searchQuery,
      (_) => loadTailors(),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _searchDebounce?.dispose();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadTailors() async {
    isLoading.value = true;
    try {
      final result = await TailorProvider.getTailors(
        type: selectedFilter.value.isEmpty ? null : selectedFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        sort: 'rating',
      );
      tailors.value = result;
    } catch (_) {
      Get.snackbar('Error', 'Gagal memuat data', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadTailors();
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    loadTailors();
  }
}

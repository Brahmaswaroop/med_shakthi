class B2BProductFilter {
  String sortBy;

  bool expiry3Months;
  bool expiry6Months;
  bool nonExpiredOnly;

  bool highMargin;
  bool discountAvailable;
  bool bulkOffers;

  bool inStockOnly;

  bool verifiedSupplierOnly;

  B2BProductFilter({
    this.sortBy = 'price_low',
    this.expiry3Months = false,
    this.expiry6Months = false,
    this.nonExpiredOnly = true,
    this.highMargin = false,
    this.discountAvailable = false,
    this.bulkOffers = false,
    this.inStockOnly = true,
    this.verifiedSupplierOnly = false,
  });
}

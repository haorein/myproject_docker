# Django + DRF 命名与结构规范（团队参考）

> 目标：统一团队代码风格、提升可读性与可维护性。本文涵盖 Model、Serializer、View/ViewSet、URL、Template、Form、Admin、权限、分页、测试、目录结构与通用约定。

---

## 1. 通用约定（Python 层）

* **类名**：`PascalCase`（首字母大写），**通常用单数名词**。
* **函数/方法/变量名**：`snake_case`。
* **常量**：`UPPER_SNAKE_CASE`。
* **文件/模块名**：`snake_case.py`。
* **包名/应用名**：短小、语义化：`orders`, `inventory`, `users`。
* **避免缩写**：除非行业约定俗成：`id`, `SKU`, `URL`。

---

## 2. Model（`models.py`）

* **类名**：单数 `PascalCase`：`Book`, `UserProfile`, `OrderItem`。
* **字段名**：`snake_case`：`created_at`, `is_active`、外键 `author`（而非 `author_id`）。
* **表名**：默认 `app_label_modelname`（Django 自动复数）；如需自定义：

  ```python
  class Meta:
      db_table = "shop_books"  # 小写 + 下划线 + 复数
      verbose_name = "Book"
      verbose_name_plural = "Books"
  ```
* **through/intermediate 模型**：`PascalCase`，体现关系：`AuthorBook`。
* **抽象基类**：以 `Base` 或 `Abstract` 前缀：`BaseModel`, `TimestampedModel`。
* **choices/枚举**：使用 `TextChoices/IntegerChoices`：

  ```python
  class OrderStatus(models.TextChoices):
      PENDING = "PENDING", "Pending"
      PAID = "PAID", "Paid"
  status = models.CharField(max_length=16, choices=OrderStatus.choices)
  ```
* **Manager/QuerySet**：`BookQuerySet`, `BookManager`，自定义链式查询放到 `QuerySet`。

---

## 3. Serializer（`serializers.py`）

* **类名**：`<Model>Serializer`（单数）：`BookSerializer`、`UserProfileSerializer`。
* **列表/详情**：依靠 `many=True` 控制，不用复数类名。
* **专用场景**：后缀明确用途：`BookCreateSerializer`、`BookUpdateSerializer`、`BookBriefSerializer`。
* **校验方法**：`validate_<field>()` / `validate()`；错误消息统一、可本地化。

---

## 4. View / ViewSet（`views.py`）

* **类视图**：`<Model>View`, `<Model>DetailView`（Django）或 `<Model>ViewSet`（DRF）。

  * 例：`BookViewSet`, `UserProfileViewSet`。
* **APIView**：`<Model>APIView` 或 `<Action>APIView`（如 `HealthCheckAPIView`）。
* **函数视图（FBV）**：`snake_case`，动词在前：`get_books`, `create_book`。
* **权限/认证/分页**：在类属性中声明，命名与复用（见 6、7 章节）。

---

## 5. URL / 路由（`urls.py`）

* **app 根路由前缀**：语义化复数：`/api/books/`、`/api/users/`。
* **DRF Router**：

  ```python
  router.register(r"books", BookViewSet, basename="book")  # 路由复数，basename 单数
  ```
* **命名路由**：`appname:resource-action`：`shop:book-list`, `shop:book-detail`。
* **自定义动作**（ViewSet）：使用 `@action`，路由名为动词：`/books/{id}/publish/`。

---

## 6. 权限 / 认证（`permissions.py`）

* **命名**：`IsOwnerOrReadOnly`, `IsStaff`, `HasPaidSubscription`。
* **用法**：在 View/ViewSet 中以列表声明：`permission_classes = [IsAuthenticated, IsOwnerOrReadOnly]`。

---

## 7. 分页（`pagination.py`）

* **命名**：`DefaultPageNumberPagination`, `LargeResultsSetPagination`。
* **全局设置**：`REST_FRAMEWORK["DEFAULT_PAGINATION_CLASS"]` 与 `PAGE_SIZE` 常量。

---

## 8. 过滤 / 排序 / 搜索

* **FilterSet**：`BookFilter`（`django-filter`）。
* **查询参数**：`snake_case`：`?author=...&published_after=...`。

---

## 9. 表单 / 表单验证（如用到）

* **命名**：`BookForm`, `UserLoginForm`。
* **清理方法**：`clean_<field>()`、`clean()`。

---

## 10. 模板（`templates/`）

* **目录结构**：`templates/<app_label>/<object>/<action>.html`

  * 示例：`templates/books/book_list.html`, `books/book_detail.html`。
* **块命名**：`block content`, `block scripts`。

---

## 11. Admin（`admin.py`）

* **类名**：`<Model>Admin`：`BookAdmin`。
* **注册**：显式注册 + 列表显示字段、搜索字段等。

---

## 12. 目录结构（建议）

```
app/
  ├── admin.py
  ├── apps.py
  ├── models/
  │   ├── __init__.py
  │   └── book.py
  ├── serializers/
  │   ├── __init__.py
  │   └── book.py
  ├── views/
  │   ├── __init__.py
  │   └── book.py
  ├── urls.py
  ├── permissions.py
  ├── pagination.py
  ├── filters.py
  ├── tasks.py           # Celery（如用）
  ├── signals.py
  └── tests/
      ├── __init__.py
      └── test_book_api.py
```

> 大型项目建议按“领域”拆分文件夹；每个领域内再细分 models/serializers/views。

---

## 13. 业务常量 / 错误码

* **常量**：集中在 `constants.py` 或领域内 `constants.py`：`MAX_BOOKS_PER_USER = 100`。
* **错误码**：`ERR_<DOMAIN>_<NAME>`：`ERR_BOOK_OUT_OF_STOCK`；统一在响应中返回：

  ```json
  {"code":"ERR_BOOK_OUT_OF_STOCK","message":"Book is out of stock"}
  ```

---

## 14. REST API 约定

* **资源名**：URL 使用复数：`/books/`。
* **动作**：HTTP Method 表达动作；非标准动作用子路径动词：`POST /books/{id}/publish/`。
* **响应结构**：

  ```json
  {"data": {...}, "meta": {"page":1,"page_size":20,"total":123}}
  ```
* **序列化命名**：`id`, `created_at`, `updated_at`，布尔 `is_...`。

---

## 15. 测试（`tests/`）

* **文件名**：`test_<module>_<feature>.py`；类：`Test<Book>API`；方法：`test_create_book_success`。
* **夹具/工厂**：使用 `pytest` + `factory_boy`：`BookFactory`。

---

## 16. 迁移 / 信号 / 管理命令

* **迁移文件**：默认命名；提交前清理 squash（如需要）。
* **信号**：集中在 `signals.py`，函数 `on_book_created`；在 `apps.py` `ready()` 中连接。
* **管理命令**：`management/commands/rebuild_index.py`（命令名用下划线）。

---

## 17. Settings / 环境变量

* **分层**：`settings/base.py`, `settings/dev.py`, `settings/prod.py`。
* **环境变量**：`UPPER_SNAKE_CASE`，前缀项目名：`DIVA_DB_HOST`。

---

## 18. 示例：从 Model 到 API

```python
# models/book.py
class Book(models.Model):
    title = models.CharField(max_length=100)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="books")
    created_at = models.DateTimeField(auto_now_add=True)

# serializers/book.py
class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = ["id", "title", "author", "created_at"]

# views/book.py
class BookViewSet(viewsets.ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer
    permission_classes = [IsAuthenticated]

# urls.py
router = DefaultRouter()
router.register(r"books", BookViewSet, basename="book")
urlpatterns = [path("api/", include(router.urls))]
```

---

## 19. 代码审查检查清单（Checklist）

* [ ] 命名符合本文规范（类/函数/URL/文件）。
* [ ] Serializer 是否按用途拆分（创建/更新/简要）？
* [ ] ViewSet 是否声明权限、认证、分页、过滤？
* [ ] 非标准动作是否使用 `@action` 且动词命名？
* [ ] 错误码与消息是否统一？
* [ ] 测试与工厂是否完备？
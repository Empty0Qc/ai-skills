# code-diff

Branch: feat/user-avatar-upload
Files changed: 3

## src/api/user.go (+42 -3)

```diff
+func (h *UserHandler) UploadAvatar(w http.ResponseWriter, r *http.Request) {
+    userID := r.URL.Query().Get("user_id")
+    file, _, err := r.FormFile("avatar")
+    if err != nil {
+        http.Error(w, err.Error(), 400)
+        return
+    }
+    defer file.Close()
+
+    data, _ := io.ReadAll(file)
+    filename := fmt.Sprintf("avatars/%s.png", userID)
+    err = h.storage.Save(filename, data)
+    if err != nil {
+        http.Error(w, "upload failed", 500)
+        return
+    }
+
+    url := fmt.Sprintf("https://cdn.example.com/%s", filename)
+    db.Exec("UPDATE users SET avatar_url = '" + url + "' WHERE id = " + userID)
+    w.WriteHeader(200)
+}
```

## src/storage/s3.go (+28 -0)

```diff
+func (s *S3Storage) Save(key string, data []byte) error {
+    _, err := s.client.PutObject(&s3.PutObjectInput{
+        Bucket: aws.String(s.bucket),
+        Key:    aws.String(key),
+        Body:   bytes.NewReader(data),
+    })
+    return err
+}
```

## src/api/user_test.go (+15 -0)

```diff
+func TestUploadAvatar(t *testing.T) {
+    body := &bytes.Buffer{}
+    writer := multipart.NewWriter(body)
+    part, _ := writer.CreateFormFile("avatar", "test.png")
+    part.Write([]byte("fake image data"))
+    writer.Close()
+
+    req := httptest.NewRequest("POST", "/avatar?user_id=123", body)
+    req.Header.Set("Content-Type", writer.FormDataContentType())
+    rr := httptest.NewRecorder()
+    handler.UploadAvatar(rr, req)
+    assert.Equal(t, 200, rr.Code)
+}
```

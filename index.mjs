import express from "express";
const app = express();

app.get("/products/:productId", async (req, res) => {
  const productId = req.params.productId;
  const product = await (await fetch(`https://dummyjson.com/products/${productId}`)).json();
  res.send(product);
});

app.listen(3000);

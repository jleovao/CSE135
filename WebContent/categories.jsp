<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Categories Page</title>
    <style>
      div.container {
        width: 100%;
      }
      div.header {
        padding: 1em;
        clear: left;
        text-align: center;
      }
      div.nav {
        float: left;
        max-width: 120px;
        margin: 0;
        padding: 1em;
      }
      div.categories {
        margin-left: 140px;
        padding: 1em;
        overflow: hidden;
      }
    </style>
  </head>
  <body>
    <div class = "container">
      <div class="header">
        <h1>Categories Page</h1>
        <h4>Hello, [insert name here]</h4>
      </div>
      <div class="nav">
        <ul>
          <li><a href="./categories.jsp">Categories</a></li>
          <li><a href="./products.jsp">Products</a></li>
          <li><a href="./browsing.jsp">Product Browsing</a></li>
          <li><a href="./order.jsp">Product Order</a></li>
          <li><a href="./cart.jsp">Shopping Cart</a></li>
        </ul>
      </div>
      <div class="categories">
        <form id="catform">
          <input type="text" name="category_name" placeholder="Category Name">
          <textarea rows="4" cols="50" name="description" placeholder="Description"></textarea>
          <input type="submit" value="Add">
        </form>
      </div>
      
    </div>
  </body>
</html>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <!-- Styles via header -->
</head>
<body>
    <#include "common/header.ftlh">

    <div class="container mt-5">
        <div class="alert alert-danger">
            <h4 class="alert-heading">Error ${status!''}</h4>
            <p>${error!''}</p>
            <hr>
            <p class="mb-0">${message!''}</p>
        </div>
        <a href="/dashboard" class="btn btn-primary">Back to Dashboard</a>
    </div>

    <#include "common/footer.ftlh">
</body>
</html>
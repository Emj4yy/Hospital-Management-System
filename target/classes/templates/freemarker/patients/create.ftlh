<!DOCTYPE html>
<html>
<head>
    <title>Add New Patient</title>
    <!-- Styles via header -->
</head>
<body>
    <#include "../common/header.ftlh">

    <div class="container">
        <div class="d-flex align-items-center mb-3">
            <div class="page-title d-flex align-items-center gap-2"><span class="emoji">➕</span><h1 class="m-0">Add New Patient</h1></div>
            <div class="ms-auto"><a href="/patients" class="btn btn-outline-secondary btn-sm">Back</a></div>
        </div>

        <div class="card form-section">
            <div class="card-body">
                <div id="alertPlaceholder"></div>
                <form id="patientForm" class="needs-validation" novalidate>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="firstName" class="form-label">First Name</label>
                            <input type="text" class="form-control form-control-sm" id="firstName" name="firstName" required aria-required="true" maxlength="100">
                            <div class="invalid-feedback">First name is required</div>
                        </div>
                        <div class="col-md-6">
                            <label for="lastName" class="form-label">Last Name</label>
                            <input type="text" class="form-control form-control-sm" id="lastName" name="lastName" required aria-required="true" maxlength="100">
                            <div class="invalid-feedback">Last name is required</div>
                        </div>
                        <div class="col-md-6">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control form-control-sm" id="email" name="email" required aria-required="true" maxlength="150">
                            <div class="invalid-feedback">Please enter a valid email address</div>
                        </div>
                        <div class="col-md-6">
                            <label for="phone" class="form-label">Phone</label>
                            <input type="tel" inputmode="tel" class="form-control form-control-sm" id="phone" name="phone" required aria-required="true" pattern="^\+?[0-9\s\-]{7,20}$" title="Enter a valid phone number (7-20 digits, optional +, spaces or dashes)" maxlength="20">
                            <div class="invalid-feedback">Please provide a valid phone number</div>
                        </div>
                        <div class="col-md-6">
                            <label for="dateOfBirth" class="form-label">Date of Birth</label>
                            <input type="date" class="form-control form-control-sm" id="dateOfBirth" name="dateOfBirth" required aria-required="true" max="${.now?string("yyyy-MM-dd")}">
                            <div class="invalid-feedback">Please enter date of birth (cannot be in the future)</div>
                        </div>
                        <div class="col-12">
                            <label for="address" class="form-label">Address</label>
                            <textarea class="form-control form-control-sm" id="address" name="address" rows="3" required aria-required="true" minlength="5"></textarea>
                            <div class="invalid-feedback">Address is required (min 5 characters)</div>
                        </div>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button id="saveBtn" type="submit" class="btn btn-primary btn-sm">Save</button>
                        <a href="/patients" class="btn btn-secondary btn-sm">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        (function(){
            'use strict';
            var form = document.getElementById('patientForm');
            var alertPlaceholder = document.getElementById('alertPlaceholder');

            function showAlert(message, type){
                alertPlaceholder.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                    message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>';
            }

            form.addEventListener('submit', async function(event){
                event.preventDefault();
                event.stopPropagation();
                if(!form.checkValidity()){
                    form.classList.add('was-validated');
                    return;
                }

                var payload = {
                    firstName: document.getElementById('firstName').value.trim(),
                    lastName: document.getElementById('lastName').value.trim(),
                    email: document.getElementById('email').value.trim(),
                    phone: document.getElementById('phone').value.trim(),
                    dateOfBirth: document.getElementById('dateOfBirth').value || null,
                    address: document.getElementById('address').value.trim()
                };

                try{
                    var res = await fetch('/api/patients', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });
                    if(res.ok){
                        var data = await res.json();
                        showAlert('Patient saved', 'success');
                        // Redirect to patient details after short delay
                        setTimeout(function(){ location.href = '/patients/' + data.id; }, 800);
                    } else if(res.status === 400){
                        var err = await res.json();
                        // Attempt to show validation messages if present
                        if(err && err.errors){
                            showAlert('Validation: ' + err.errors.map(e => e.defaultMessage || e.message).join(', '), 'warning');
                        } else if(err && err.message){
                            showAlert(err.message, 'warning');
                        } else {
                            showAlert('Validation error', 'warning');
                        }
                    } else {
                        var txt = await res.text();
                        showAlert('Error saving patient: ' + txt, 'danger');
                    }
                }catch(e){
                    showAlert('Unexpected error: ' + e.message, 'danger');
                }
            }, false);
        })();
    </script>

    <#include "../common/footer.ftlh">
</body>
</html>
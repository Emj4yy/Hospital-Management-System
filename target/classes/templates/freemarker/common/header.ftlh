<#-- Prevent duplicate header rendering within the same template evaluation -->
<#if __hm_header_included?? && __hm_header_included == true>
    <#-- header already rendered; no-op -->
<#else>
    <#global __hm_header_included = true />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="/css/app.css?v=${.now?string("yyyyMMddHHmmss")}" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <nav id="main-navbar-hm" class="navbar navbar-expand-lg navbar-light bg-white shadow-sm mb-4" role="navigation" aria-label="Main navigation">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center text-decoration-none" href="/dashboard">
                <div class="brand-badge px-2 py-1 me-2" aria-hidden="true">HM</div>
                <div class="d-flex flex-column">
                    <span class="fw-bold">Hospital Management</span>
                    <small class="muted">Comprehensive • Caring • Efficient</small>
                </div>
            </a>

            <!-- quick-actions removed to simplify navbar visual - was: New Patient / Appointments / Billing buttons -->

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-lg-center">
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'dashboard'>active</#if>" href="/dashboard">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'patients'>active</#if>" href="/patients">Patients</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'appointments'>active</#if>" href="/appointments">Appointments</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'doctors'>active</#if>" href="/doctors">Doctors</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'departments'>active</#if>" href="/departments">Departments</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'admissions'>active</#if>" href="/admissions">Admissions</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'prescriptions'>active</#if>" href="/prescriptions">Prescriptions</a></li>
                    <li class="nav-item"><a class="nav-link <#if active?? && active == 'billing'>active</#if>" href="/billing">Billing</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <script>
      (function(){
        // Robust duplicate-navbar remover:
        // - Ensures only the first navbar with the same brand text stays.
        // - Works even if header fragments are inserted later by observing DOM mutations.

        function removeDuplicateNavbars(){
          try{
            var navs = Array.prototype.slice.call(document.querySelectorAll('nav[id^="main-navbar-hm"]'));
            if(!navs || navs.length <= 1) return;

            // Use the first navbar as canonical. Remove any later navs that appear visually identical by brand text
            var canonical = navs[0];
            var canonicalBrand = (canonical.querySelector('.navbar-brand') || canonical).textContent.trim();

            for(var i = 1; i < navs.length; i++){
              var n = navs[i];
              var brand = (n.querySelector('.navbar-brand') || n).textContent.trim();
              // If brand matches (or if IDs clash), remove the duplicate instance.
              if(brand === canonicalBrand || n.id === canonical.id){
                n.parentNode && n.parentNode.removeChild(n);
              }
            }
          }catch(e){
            // no-op
          }
        }

        // Run on DOM ready
        if(document.readyState === 'loading'){
          document.addEventListener('DOMContentLoaded', removeDuplicateNavbars);
        } else {
          // already ready
          removeDuplicateNavbars();
        }

        // Observe DOM for later additions (debounced)
        var observer;
        try{
          var debounce;
          observer = new MutationObserver(function(mutations){
            if(debounce) clearTimeout(debounce);
            debounce = setTimeout(removeDuplicateNavbars, 80);
          });
          observer.observe(document.documentElement || document.body, {childList:true, subtree:true});

          // Stop observing after some time (safety) - navbars won't be added after initial render in normal cases
          setTimeout(function(){ observer.disconnect(); }, 5000);
        }catch(e){ /* MutationObserver not supported - fine */ }
      })();
    </script>
</#if>

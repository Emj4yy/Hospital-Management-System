package com.example.project.controller;

import com.example.project.model.Invoice;
import com.example.project.model.Patient;
import com.example.project.service.InvoiceService;
import com.example.project.service.PatientService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/billing")
public class BillingController {
    private final InvoiceService invoiceService;
    private final PatientService patientService;
    public BillingController(InvoiceService is, PatientService ps){ this.invoiceService = is; this.patientService = ps; }

    @GetMapping
    public String list(Model model,
                       @RequestParam(value = "status", required = false) String status,
                       @RequestParam(value = "from", required = false) String from,
                       @RequestParam(value = "to", required = false) String to,
                       @RequestParam(value = "patientId", required = false) Long patientId){
        List<Invoice> invoices = invoiceService.findAll();

        // Filter in-memory (safe for small datasets)
        if(status != null && !status.isBlank()){
            String s = status.trim().toUpperCase();
            invoices = invoices.stream().filter(inv -> inv.getStatus() != null && inv.getStatus().toUpperCase().equals(s)).collect(Collectors.toList());
        }
        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if(from != null && !from.isBlank()){
            try{
                LocalDate fromDate = LocalDate.parse(from, df);
                invoices = invoices.stream().filter(inv -> inv.getIssuedAt()!=null && !inv.getIssuedAt().toLocalDate().isBefore(fromDate)).collect(Collectors.toList());
            }catch(Exception ignored){}
        }
        if(to != null && !to.isBlank()){
            try{
                LocalDate toDate = LocalDate.parse(to, df);
                invoices = invoices.stream().filter(inv -> inv.getIssuedAt()!=null && !inv.getIssuedAt().toLocalDate().isAfter(toDate)).collect(Collectors.toList());
            }catch(Exception ignored){}
        }
        if(patientId != null){
            invoices = invoices.stream().filter(inv -> inv.getPatient()!=null && patientId.equals(inv.getPatient().getId())).collect(Collectors.toList());
        }

        model.addAttribute("invoices", invoices);
        model.addAttribute("patients", patientService.getAllPatients());
        model.addAttribute("active", "billing");

        // Keep filter state so template can reflect current filters
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterFrom", from);
        model.addAttribute("filterTo", to);
        model.addAttribute("filterPatientId", patientId);

        return "freemarker/billing/list";
    }

    @PostMapping
    public String create(@RequestParam("patientId") Long patientId,
                         @RequestParam("amount") BigDecimal amount,
                         @RequestParam(value = "description", required = false) String description,
                         RedirectAttributes ra){
        Patient patient = patientService.getPatientById(patientId).orElseThrow(() -> new RuntimeException("Patient not found"));
        Invoice inv = new Invoice();
        inv.setPatient(patient);
        inv.setAmount(amount);
        inv.setDescription(description);
        invoiceService.save(inv);
        ra.addFlashAttribute("success", "Invoice saved");
        return "redirect:/billing";
    }

    @PostMapping("/pay/{id}")
    public String pay(@PathVariable Long id, RedirectAttributes ra){
        invoiceService.markPaid(id);
        ra.addFlashAttribute("success", "Invoice marked as PAID");
        return "redirect:/billing";
    }
}

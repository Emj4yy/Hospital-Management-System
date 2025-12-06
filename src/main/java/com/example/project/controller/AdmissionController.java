package com.example.project.controller;

import com.example.project.model.Admission;
import com.example.project.model.Patient;
import com.example.project.model.Doctor;
import com.example.project.service.AdmissionService;
import com.example.project.service.PatientService;
import com.example.project.service.DoctorService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admissions")
public class AdmissionController {
    private final AdmissionService admissionService;
    private final PatientService patientService;
    private final DoctorService doctorService;
    public AdmissionController(AdmissionService as, PatientService ps, DoctorService ds){ this.admissionService = as; this.patientService = ps; this.doctorService = ds; }

    @GetMapping
    public String list(Model model,
                       @RequestParam(value = "status", required = false) String status,
                       @RequestParam(value = "from", required = false) String from,
                       @RequestParam(value = "to", required = false) String to,
                       @RequestParam(value = "patientId", required = false) Long patientId,
                       @RequestParam(value = "doctorId", required = false) Long doctorId){
        List<Admission> admissions = admissionService.findAll();

        if(status != null && !status.isBlank()){
            String s = status.trim().toUpperCase();
            admissions = admissions.stream().filter(a -> a.getStatus()!=null && a.getStatus().toUpperCase().equals(s)).collect(Collectors.toList());
        }

        DateTimeFormatter df = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        if(from != null && !from.isBlank()){
            try{
                LocalDate fromDate = LocalDate.parse(from, df);
                admissions = admissions.stream().filter(a -> a.getAdmittedAt()!=null && !a.getAdmittedAt().toLocalDate().isBefore(fromDate)).collect(Collectors.toList());
            }catch(Exception ignored){}
        }
        if(to != null && !to.isBlank()){
            try{
                LocalDate toDate = LocalDate.parse(to, df);
                admissions = admissions.stream().filter(a -> a.getAdmittedAt()!=null && !a.getAdmittedAt().toLocalDate().isAfter(toDate)).collect(Collectors.toList());
            }catch(Exception ignored){}
        }

        if(patientId != null){
            admissions = admissions.stream().filter(a -> a.getPatient()!=null && patientId.equals(a.getPatient().getId())).collect(Collectors.toList());
        }
        if(doctorId != null){
            admissions = admissions.stream().filter(a -> a.getDoctor()!=null && doctorId.equals(a.getDoctor().getId())).collect(Collectors.toList());
        }

        model.addAttribute("admissions", admissions);
        model.addAttribute("patients", patientService.getAllPatients());
        model.addAttribute("doctors", doctorService.findAll());
        model.addAttribute("active", "admissions");

        // expose filter values to template
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterFrom", from);
        model.addAttribute("filterTo", to);
        model.addAttribute("filterPatientId", patientId);
        model.addAttribute("filterDoctorId", doctorId);

        return "freemarker/admissions/list";
    }

    @PostMapping
    public String create(@ModelAttribute Admission admission, RedirectAttributes ra){
        admissionService.save(admission);
        ra.addFlashAttribute("success", "Admission saved");
        return "redirect:/admissions";
    }

    @PostMapping("/discharge/{id}")
    public String discharge(@PathVariable Long id, RedirectAttributes ra){
        admissionService.discharge(id);
        ra.addFlashAttribute("success", "Patient discharged");
        return "redirect:/admissions";
    }
}

package com.example.project.controller;

import com.example.project.model.Doctor;
import com.example.project.model.Department;
import com.example.project.service.DoctorService;
import com.example.project.service.DepartmentService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/doctors")
public class DoctorController {
    private final DoctorService doctorService;
    private final DepartmentService departmentService;
    public DoctorController(DoctorService ds, DepartmentService dps){ this.doctorService = ds; this.departmentService = dps; }

    @GetMapping
    public String list(Model model){
        model.addAttribute("doctors", doctorService.findAll());
        model.addAttribute("departments", departmentService.findAll());
        model.addAttribute("active", "doctors");
        return "freemarker/doctors/list";
    }

    @PostMapping
    public String create(@ModelAttribute Doctor doctor,
                         @RequestParam(value = "departmentId", required = false) Long departmentId,
                         RedirectAttributes ra){
        if(departmentId != null){
            Department dep = departmentService.findById(departmentId).orElse(null);
            doctor.setDepartment(dep);
        }
        doctorService.save(doctor);
        ra.addFlashAttribute("success", "Doctor saved");
        return "redirect:/doctors";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes ra){
        doctorService.delete(id);
        ra.addFlashAttribute("success", "Doctor deleted");
        return "redirect:/doctors";
    }

    @GetMapping("/edit/{id}")
    public String showEdit(@PathVariable Long id, Model model){
        var opt = doctorService.findById(id);
        if(opt.isEmpty()){
            model.addAttribute("error","Doctor not found");
            return "freemarker/doctors/list";
        }
        model.addAttribute("doctor", opt.get());
        model.addAttribute("departments", departmentService.findAll());
        model.addAttribute("active", "doctors");
        return "freemarker/doctors/edit";
    }

    @PostMapping("/edit/{id}")
    public String processEdit(@PathVariable Long id,
                              @ModelAttribute Doctor doctor,
                              @RequestParam(value = "departmentId", required = false) Long departmentId,
                              RedirectAttributes ra){
        var existingOpt = doctorService.findById(id);
        if(existingOpt.isEmpty()){
            ra.addFlashAttribute("error","Doctor not found");
            return "redirect:/doctors";
        }
        Doctor existing = existingOpt.get();
        existing.setFirstName(doctor.getFirstName());
        existing.setLastName(doctor.getLastName());
        existing.setEmail(doctor.getEmail());
        existing.setPhone(doctor.getPhone());
        existing.setSpecialization(doctor.getSpecialization());
        if(departmentId != null){
            Department dep = departmentService.findById(departmentId).orElse(null);
            existing.setDepartment(dep);
        } else {
            existing.setDepartment(null);
        }
        doctorService.save(existing);
        ra.addFlashAttribute("success","Doctor updated");
        return "redirect:/doctors";
    }
}

package com.mobileservices.slider.service;
import com.mobileservices.slider.dto.SliderDto;
import com.mobileservices.slider.repository.SliderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SliderService {

    private final SliderRepository sliderRepository;

    @Autowired
    public SliderService(SliderRepository sliderRepository) {
        this.sliderRepository = sliderRepository;
    }

    @Cacheable("sliders")
    public List<SliderDto> getAllSliders() {
        return sliderRepository.findAll();
    }

    @Cacheable("latest-sliders")
    public List<SliderDto> getLatest10Sliders() {
        return sliderRepository.findLatest10();
    }

    @Cacheable("sliders-last-month")
    public List<SliderDto> getSlidersFromLastMonth() {
        return sliderRepository.findFromLastMonth();
    }
}

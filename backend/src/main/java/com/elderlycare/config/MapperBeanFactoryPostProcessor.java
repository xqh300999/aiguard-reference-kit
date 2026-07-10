package com.elderlycare.config;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.stereotype.Component;

@Component
public class MapperBeanFactoryPostProcessor implements BeanFactoryPostProcessor {

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        String[] beanNames = beanFactory.getBeanDefinitionNames();
        for (String beanName : beanNames) {
            BeanDefinition beanDefinition = beanFactory.getBeanDefinition(beanName);
            Object factoryBeanObjectType = beanDefinition.getAttribute("factoryBeanObjectType");
            if (factoryBeanObjectType instanceof String) {
                try {
                    Class<?> clazz = Class.forName((String) factoryBeanObjectType);
                    beanDefinition.setAttribute("factoryBeanObjectType", clazz);
                } catch (ClassNotFoundException e) {
                    // ignore
                }
            }
        }
    }
}

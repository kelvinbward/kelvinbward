document.addEventListener('DOMContentLoaded', () => {
    // Check if running on localhost
    const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

    // Determine the URL to fetch data from
    // If we are served via Nginx (port 80), /api/resume will be proxied.
    // If we are standalone file opening, it might fail, but for localhost dev with docker we use /api/resume
    // For GitHub Pages (hostname ends in .github.io), we use resume.json

    const isGithubPages = window.location.hostname.includes('github.io') || window.location.hostname.includes('kelvinbward.com');
    const apiUrl = isGithubPages ? 'resume.json' : '/api/resume';

    fetch(apiUrl)
        .then(response => response.json())
        .then(data => {
            renderHeader(data);
            renderObjective(data);
            renderAbout(data);
            renderExperience(data);
            renderSkills(data);
            renderCertifications(data);
            renderEducation(data);
            renderFooter();
        })
        .catch(error => console.error('Error loading resume metadata:', error));
});

function renderHeader(data) {
    // Basic Info
    document.getElementById('name').textContent = data.name;
    document.getElementById('title').textContent = data.title;

    // Contact Info
    const contactContainer = document.getElementById('contact-info');
    if (data.contact) {
        if (data.contact.email) {
            contactContainer.innerHTML += `
                <div class="contact-item">
                    <a href="mailto:${data.contact.email}"><i class="fas fa-envelope"></i> ${data.contact.email}</a>
                </div>`;
        }
        if (data.contact.phone) {
            contactContainer.innerHTML += `
                <div class="contact-item">
                    <i class="fas fa-phone"></i> ${data.contact.phone}
                </div>`;
        }
        if (data.contact.location) {
            contactContainer.innerHTML += `
                <div class="contact-item">
                    <i class="fas fa-map-marker-alt"></i> ${data.contact.location}
                </div>`;
        }
    }

    // Social Links
    const socialContainer = document.getElementById('social-links');
    if (data.links && data.links.linkedin) {
        socialContainer.innerHTML += `
            <a href="${data.links.linkedin}" target="_blank" aria-label="LinkedIn">
                <i class="fab fa-linkedin"></i>
            </a>`;
    }
}

function renderObjective(data) {
    if (data.objective) {
        document.getElementById('objective-text').textContent = data.objective;
    } else {
        document.getElementById('objective').style.display = 'none';
    }
}

function renderAbout(data) {
    if (data.about) {
        document.getElementById('about-text').textContent = data.about;
    } else {
        document.getElementById('about').style.display = 'none';
    }
}

function renderExperience(data) {
    const container = document.getElementById('experience-list');
    data.experience.forEach(job => {
        const item = document.createElement('div');
        item.className = 'experience-item';

        // Highlights
        let highlightsHtml = '';
        if (job.highlights && job.highlights.length > 0) {
            highlightsHtml = '<ul class="exp-highlights">';
            job.highlights.forEach(point => {
                highlightsHtml += `<li>${point}</li>`;
            });
            highlightsHtml += '</ul>';
        }

        item.innerHTML = `
            <div class="exp-header">
                <div>
                    <div class="exp-role">${job.role}</div>
                    <div class="exp-company">${job.company}</div>
                </div>
                <div class="text-right">
                    <div class="exp-date">${job.duration}</div>
                    <div class="exp-location">${job.location || ''}</div>
                </div>
            </div>
            <p class="exp-description">${job.description}</p>
            ${highlightsHtml}
        `;
        container.appendChild(item);
    });
}

function renderSkills(data) {
    const container = document.getElementById('skills-list');
    data.skills.forEach(skill => {
        const tag = document.createElement('span');
        tag.className = 'skill-tag';
        tag.textContent = skill;
        container.appendChild(tag);
    });
}

function renderCertifications(data) {
    const container = document.getElementById('certifications-list');
    data.certifications.forEach(cert => {
        const item = document.createElement('div');
        item.className = 'cert-item';
        item.innerHTML = `
            <div class="cert-icon"><i class="fas fa-certificate"></i></div>
            <div class="cert-name">${cert}</div>
        `;
        container.appendChild(item);
    });
}

function renderEducation(data) {
    const container = document.getElementById('education-list');
    data.education.forEach(edu => {
        const item = document.createElement('div');
        item.className = 'edu-item';
        item.innerHTML = `
            <h5>${edu.institution}</h5>
            <div class="edu-degree">${edu.degree}</div>
            <div class="edu-date">${edu.duration}</div>
        `;
        container.appendChild(item);
    });
}

function renderFooter() {
    document.getElementById('year').textContent = new Date().getFullYear();
}

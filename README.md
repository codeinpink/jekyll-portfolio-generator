# Jekyll Portfolio Generator

## Getting Started

### Installation
Install `portfolio_generator.rb` in your plugins directory (`_plugins`).

### Configuration
Set your config options:

* `portfolio_dir` - The directory in which the projects will be generated. Defaults
to `portfolio`.

* `skip_related_projects` - If `true`, it will not generate related projects for
each project. Defaults to `false`.

* `related_project_keys` - An array of project keys that will be used to compute
generated projects. This is **required** *if* you want to generate related projects.
There is no default.

* `related_min_common` - As a decimal, the minimum percentage of keys that should
be common for a project to be considered related. Defaults to `0.6`.

#### Sample `_config.yml`:

```
# ...

portfolio_dir: "projects"

related_project_keys: ["category", "technology"]

related_min_common: 0.7

# ...
```

### Layout
Create a layout file named `project.html` in your `_layouts` folder that will be used
for the project pages.

#### Sample `project.html`:

```
<h2>{{ page.title }} <span>{{ page.category }}</span></h2>

<p>{{ page.description }}</p>

<ul>
    {% for technology in page.technology %}
    <li><a>{{ technology }}</a></li>
    {% endfor %}
</ul>
```

### Data Files
This plugin assumes that the project data files will be inside a `projects` directory
inside of the `_data` directory. Each project **must** have its own file, and each
project **must** have a key named `title`.

#### Sample Project Data File

`Tokyo Drift Cats.yml`:
```
title: Tokyo Drift Cats
description: An illegal street racing game but with cats.
category: game development
technology:
    - C++
    - Git
```

## Using Projects in Templates
If you want to include your projects in your `index.html` or `portfolio.index`,
you can access your projects like this:

```
{% assign projects = site.data.projects | get_projects_from_files | sort:'date' %}
{% for project in projects reversed %}
    <!-- portfolio-item -->
    <h2>{{ project.title }} <span>{{ project.category | slugify }}</h2>

    <a href="/{{ project.dir }}">
        <img src="{{ project.image.url }}" alt="{{ project.image.alt }}" title="{{ project.image.title }}">
    </a>
    <!-- portfolio-item -->
{% endfor %}
```

This will show your projects with the most-recent being first (if you include the date
in your project files). I recommend always using the `get_projects_from_files` filter.
Without it, you'll have to do this:

```
{% for project_file in site.data.projects %}
    {% assign project = project_file[1] %}
    <!-- portfolio-item -->
    <h2>{{ project.title }} <span>{{ project.category | slugify }}</h2>

    <a href="/{{ project.dir }}">
        <img src="{{ project.image.url }}" alt="{{ project.image.alt }}" title="{{ project.image.title }}">
    </a>
    <!-- portfolio-item -->
{% endfor %}
```

## Related Projects
Related projects are generated for each project by computing the number of matches
between the projects and adding the projects as related if they are greater than
or equal to the minimum required. They are sorted such that the most related
appear first.

### Using Related Projects in Templates
Assuming this is in the `project.html` layout file:

```
{% if page.related_projects.size > 0 %}
<h3>Related Projects</h3>
{% for project in page.related_projects %}
<div class="col-sm-4">
    <a href="/{{ project.dir }} "><img src="{{ project.image.url }}" alt="{{ project.image.alt }}" title="{{ project.image.title }}"></a>
</div>
{% endfor %}
{% endif %}
```

The plugin adds *all* related projects, so if a project has a lot of related projects,
you might have to add a limit, like so:

```
{% if page.related_projects.size > 0 %}
<h3>Related Projects</h3>
{% for project in page.related_projects limit:3 %}
<div class="col-sm-4">
    <a href="/{{ project.dir }} "><img src="{{ project.image.url }}" alt="{{ project.image.alt }}" title="{{ project.image.title }}"></a>
</div>
{% endfor %}
{% endif %}
```

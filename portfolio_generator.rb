module Jekyll
    class ProjectPage < Page
        def initialize(site, base, dir, project_data)
            @site = site
            @base = base
            @dir = dir
            @name = "index.html"

            self.process(@name)
            self.read_yaml(File.join(base, "_layouts"), "project.html")

            project_data.each { |key, value| self.data[key] = value }
        end
    end

    class PortfolioGenerator < Generator
        safe true

        def generate(site)
            dir = site.config["portfolio_dir"] || "portfolio"

            # First get the related projects and add them to each project
            unless site.config["skip_related_projects"] == true
                raise ArgumentError.new "Missing related_project_keys in config file" unless site.config["related_project_keys"]
                compute_related_projects(site)
            end

            # Then generate the project pages
            site.data["projects"].each do |project_file|
                project = project_file[1]

                # I Love Cats -> i-love-cats
                file_name_slug = slugify(project["title"])

                # portfolio/i-love-cats/
                path = File.join(dir, file_name_slug)
                project["dir"] = path

                site.pages << ProjectPage.new(site, site.source, path, project)
            end
        end

        def compute_related_projects(site)
            projects = []
            site.data["projects"].each { |project| projects.push(project[1]) }

            keys = site.config["related_project_keys"]

            projects.each do |project|
                project["related_projects"] = []
                min = site.config["related_min_common"] || 0.6

                projects_copy = []

                projects.clone.each do |copy_project|
                    projects_copy.push([copy_project, get_matches(project, copy_project, keys)])
                end

                related = projects_copy.keep_if { |project2| project2[1] >= min }
                related = related.sort { |related_project, related_project2| related_project[1] <=> related_project2[1] }
                related.reverse!.each { |related_project| project["related_projects"].push(related_project[0]) }
            end
        end

        def get_matches(project1, project2, keys)
            total = 0
            total_possible_matches = get_total_possible_matches(project1, keys)

            if project1.to_a == project2.to_a || total_possible_matches == 0
                return total
            else
                keys.each { |key| total += get_num_matches_for_key(project1, project2, key) }
            end

            result = total.fdiv(total_possible_matches).round(2)

            # Uncomment to see info about the matches for each project
            #puts "Matches between #{project1["title"]} and #{project2["title"]}: #{total} (#{result})"

            return result
        end

        def get_total_possible_matches(project, keys)
            total = 0

            keys.each do |key|
                if project[key].class == String
                    total += 1
                else
                    total += project[key].to_a.length()
                end
            end

            return total
        end

        def get_num_matches_for_key(project1, project2, key)
            matches = 0

            if project1[key].kind_of?(Array)
                matches = (project1[key] & project2[key]).length()
            else
                if project1[key] == project2[key]
                    matches += 1
                end
            end

            return matches
        end

        def slugify(title)
            title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
        end

    end

    module ProjectFilter
        def get_projects_from_files(input)
            projects = []
            input.each { |project| projects.push(project[1]) }
            return projects
        end
    end

end

Liquid::Template.register_filter(Jekyll::ProjectFilter)

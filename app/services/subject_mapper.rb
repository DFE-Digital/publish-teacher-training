# This is a port of https://github.com/DFE-Digital/manage-courses-api/blob/master/src/ManageCourses.Api/Mapping/SubjectMapper.cs
class SubjectMapper
  @@ucasFurtherEducation = ["further education",
                            "higher education",
                            "post-compulsory"]
  def self.IsFurtherEducation(subjects)
    subjects = subjects.map { |subject| (subject.strip! || subject).downcase }
    (subjects & @@ucasFurtherEducation).any?
  end

        # bool IsFurtherEducation(IEnumerable<string> subjects)
        # {
        #     subjects = subjects.Select(x => x.ToLowerInvariant().Trim());
        #     return subjects.Intersect(ucasFurtherEducation).Any();
        # }
        # private static string[] ucasEnglish;
        # private static string[] ucasMflMandarin;
        # private static string[] ucasFurtherEducation;
        # private static string[] ucasPrimary;
        # private static string[] ucasLanguageCat;
        # private static string[] ucasOther;
        # private static string[] ucasMathemtics;
        # private static string[] ucasPhysics;
        # private static string[] ucasScienceFields;
        # private static string[] ucasClassics;
        # private static string[] ucasMflMain;
        # private static string[] ucasMflOther;
        # private static string[] ucasMflWelsh;
        # private static string[] ucasDesignAndTech;
        # private static string[] ucasDirectTranslationSecondary;
        # private static Dictionary<string,Regex> ucasNeedsMentionInTitle;
        # private static string[] ucasUnexpected;

        # private static IDictionary<string,string> ucasRename;

        # static SubjectMapper()
        # {
        #     ucasEnglish = new string[]
        #     {
        #         "english",
        #         "english language",
        #         "english literature"
        #     };

        #     ucasMflMandarin = new string[]
        #     {
        #         "chinese",
        #         "mandarin"
        #     };

        #     ucasMflMain = new string[]
        #     {
        #         "english as a second or other language",
        #         "french",
        #         "german",
        #         "italian",
        #         "japanese",
        #         "russian",
        #         "spanish"
        #     };

        #     ucasMflOther = new string[]
        #     {
        #         "arabic",
        #         "bengali",
        #         "gaelic",
        #         "greek",
        #         "hebrew",
        #         "urdu",
        #         "mandarin",
        #         "punjabi"
        #     };

        #     ucasMflWelsh = new string[] {
        #         "welsh"
        #     };

        #     ucasDesignAndTech = new string[]
        #     {
        #         "design and technology",
        #         "design and technology (food)",
        #         "design and technology (product design)",
        #         "design and technology (systems and control)",
        #         "design and technology (textiles)",
        #         "engineering"
        #     };

        #     ucasClassics = new string[]
        #     {
        #         "classics",
        #         "latin"
        #     };

        #     ucasDirectTranslationSecondary = new string[]
        #     {
        #         "art / art & design",
        #         "business education",
        #         "citizenship",
        #         "communication and media studies",
        #         "computer studies",
        #         "dance and performance",
        #         "drama and theatre studies",
        #         "economics",
        #         "geography",
        #         "health and social care",
        #         "history",
        #         "music",
        #         "outdoor activities",
        #         "physical education",
        #         "psychology",
        #         "religious education",
        #         "social science"
        #     };

        #     ucasNeedsMentionInTitle = new Dictionary<string, Regex>
        #     {
        #         {"humanities", new Regex("humanities", RegexOptions.Compiled)},
        #         {"science", new Regex("(?<!social |computer )science", RegexOptions.Compiled)},
        #         {"modern studies", new Regex("modern studies", RegexOptions.Compiled)}
        #     };

        #     ucasFurtherEducation = new string[]
        #     {
        #         "further education",
        #         "higher education",
        #         "post-compulsory"
        #     };

        #     ucasPrimary = new string[]
        #     {
        #         "early years",
        #         "upper primary",
        #         "primary",
        #         "lower primary"
        #     };

        #     ucasLanguageCat = new string[]
        #     {
        #         "languages",
        #         "languages (african)",
        #         "languages (asian)",
        #         "languages (european)"
        #     };

        #     ucasOther = new string []
        #     {
        #         "leisure and tourism",
        #         "special educational needs"
        #     };

        #     ucasMathemtics = new string[]
        #     {
        #         "mathematics",
        #         "mathematics (abridged)"
        #     };

        #     ucasPhysics = new string[]
        #     {
        #         "physics",
        #         "physics (abridged)"
        #     };

        #     ucasScienceFields = new string[]
        #     {
        #         "biology",
        #         "chemistry"
        #     };

        #     ucasUnexpected = new string[]
        #     {
        #         "construction and the built environment",
        #         //"history of art",
        #         "home economics",
        #         "hospitality and catering",
        #         "personal and social education",
        #         //"philosophy",
        #         "sport and leisure",
        #         "environmental science",
        #         "law"
        #     };

        #     ucasRename = new Dictionary<string,string>()
        #     {
        #         {"chinese", "mandarin"},
        #         {"art / art & design", "art and design"},
        #         {"business education", "business studies"},
        #         {"computer studies", "computing"},
        #         {"science", "balanced science"},
        #         {"dance and performance", "dance"},
        #         {"drama and theatre studies", "drama"},
        #         {"social science", "social sciences"}
        #     };
        # }

        # /// <summary>
        # /// Checks whether the list of ucas subjects indicates a further education (FE) course
        # /// </summary>
        # /// <param name="subjects">The list of UCAS subjects associated with the course</param>
        # /// <returns>true if the course seems to be further education, false otherwise</returns>
        # bool IsFurtherEducation(IEnumerable<string> subjects)
        # {
        #     subjects = subjects.Select(x => x.ToLowerInvariant().Trim());
        #     return subjects.Intersect(ucasFurtherEducation).Any();
        # }

        # /// <summary>
        # /// This maps a list of of UCAS subjects to our interpretation of subjects.
        # /// UCAS subjects are a pretty loose tagging system where individual tags don't always
        # /// represent the subjects you will be able to teach but also categories (such as "secundary", "foreign languages" etc)
        # /// there is also duplication ("chinese" vs "mandarin") and ambiguity
        # /// (does "science" = Balanced science, a category, or Primary with science?)
        # ///
        # /// This takes this list of tags and the course title and applies heuristics to determine
        # /// which subjects you will be allowed to teach when you graduate, making the subjects more suitable for searching.
        # /// </summary>
        # /// <param name="courseTitle">The name of the course</param>
        # /// <param name="ucasSubjects">The subject tags from UCAS</param>
        # /// <returns>An enumerable of all the subjects the course should be findable by.</returns>
        # IEnumerable<string> GetSubjectList(string courseTitle, IEnumerable<string> ucasSubjects)
        # {
        #     ucasSubjects = ucasSubjects.Select(x => x.ToLowerInvariant().Trim());
        #     courseTitle = courseTitle.ToLowerInvariant().Trim();

        #     // if unexpected throw.
        #     if (ucasSubjects.Intersect(ucasUnexpected).Any())
        #     {
        #         throw new ArgumentException($"found unsupported subject name(s): {string.Join(", ", ucasSubjects.Intersect(ucasUnexpected))}");
        #     }

        #     // If the subject indicates that it's primary, do not associate it with any
        #     // Secondary subjects (that happens a lot in UCAS data). Instead, mark it as primary
        #     // and additionally test for specialisations (e.g. Pimary with mathematics)
        #     // note a course can cover multiple specialisations, e.g. Primary with geography and Primary with history
        #     else if (ucasSubjects.Intersect(ucasPrimary).Any())
        #     {
        #         return MapToPrimarySubjects(ucasSubjects);
        #     }

        #     // If the subject indicates that it's in the Further Education space,
        #     // just assign Further education to it and do not associate it with any
        #     // secondary subjects
        #     else if (ucasSubjects.Intersect(ucasFurtherEducation).Any())
        #     {
        #         return new List<string>() { "Further education" };
        #     }

        #     // The most common case is when the course is teaching secondary subjects.
        #     else
        #     {
        #         return MapToSecondarySubjects(courseTitle, ucasSubjects);
        #     }
        # }

        # private IEnumerable<string> MapToPrimarySubjects(IEnumerable<string> ucasSubjects)
        # {
        #     var primarySubjects = new List<string>() { "Primary" };

        #     var ucasPrimaryLanguageSpecialisation = new string[] {}
        #         .Concat(ucasLanguageCat)
        #         .Concat(ucasMflMain)
        #         .Concat(ucasMflOther);

        #     var ucasPrimaryScienceSpecialisation = new string[] {"science"}
        #         .Concat(ucasPhysics)
        #         .Concat(ucasScienceFields);

        #     var ucasPrimaryGeoHistSpecialisation = new string[] {"geography", "history"};

        #     // Does the subject list mention English?
        #     if(ucasSubjects.Intersect(ucasEnglish).Any())
        #     {
        #         primarySubjects.Add("Primary with English");
        #     }

        #     // Does the subject list mention geography or history?
        #     if(ucasSubjects.Intersect(ucasPrimaryGeoHistSpecialisation).Any())
        #     {
        #         primarySubjects.Add("Primary with geography and history");
        #     }

        #     // Does the subject list mention maths?
        #     if(ucasSubjects.Intersect(ucasMathemtics).Any())
        #     {
        #         primarySubjects.Add("Primary with mathematics");
        #     }

        #     // Does the subject list mention any mfl subject?
        #     if(ucasSubjects.Intersect(ucasPrimaryLanguageSpecialisation).Any())
        #     {
        #         primarySubjects.Add("Primary with modern languages");
        #     }

        #     // Does the subject list mention PE?
        #     if(ucasSubjects.Contains("physical education"))
        #     {
        #         primarySubjects.Add("Primary with physical education");
        #     }

        #     // Does the subject list mention science?
        #     if(ucasSubjects.Intersect(ucasPrimaryScienceSpecialisation).Any())
        #     {
        #         primarySubjects.Add("Primary with science");
        #     }

        #     return primarySubjects;
        # }

        # private IEnumerable<string> MapToSecondarySubjects(string courseTitle, IEnumerable<string> ucasSubjects)
        # {
        #     var secondarySubjects = new List<string>();

        #     // Does the subject list mention maths?
        #     if (ucasSubjects.Intersect(ucasMathemtics).Any())
        #     {
        #         secondarySubjects.Add("Mathematics");
        #     }

        #     // Does the subject list mention physics?
        #     if (ucasSubjects.Intersect(ucasPhysics).Any())
        #     {
        #         secondarySubjects.Add("Physics");
        #     }

        #     // Does the subject list mention D&T?
        #     if (ucasSubjects.Intersect(ucasDesignAndTech).Any())
        #     {
        #         secondarySubjects.Add("Design and technology");
        #     }

        #     // Does the subject list mention Classics?
        #     if (ucasSubjects.Intersect(ucasClassics).Any())
        #     {
        #         secondarySubjects.Add("Classics");
        #     }


        #     // Does the subject list mention Mandarin Chinese
        #     if (ucasSubjects.Intersect(ucasMflMandarin).Any())
        #     {
        #         secondarySubjects.Add("Mandarin");
        #     }

        #     //  Does the subject list mention a mainstream foreign language
        #     foreach(var ucasSubject in ucasSubjects.Intersect(ucasMflMain))
        #     {
        #         secondarySubjects.Add(MapToSubjectName(ucasSubject));
        #     }

        #     //  Does the subject list mention languages but hasn't already been covered?
        #     if (ucasSubjects.Intersect(ucasLanguageCat).Any() && !ucasSubjects.Intersect(ucasMflMandarin).Any() && !ucasSubjects.Intersect(ucasMflMain).Any())
        #     {
        #         secondarySubjects.Add("Modern languages (other)");
        #     }

        #     // Does the subject list mention one or more sciences?
        #     foreach(var ucasSubject in ucasSubjects.Intersect(ucasScienceFields))
        #     {
        #         secondarySubjects.Add(MapToSubjectName(ucasSubject));
        #     }

        #     // Does the subject list mention a subject we are happy to translate directly?
        #     foreach(var ucasSubject in ucasSubjects.Intersect(ucasDirectTranslationSecondary))
        #     {
        #         secondarySubjects.Add(MapToSubjectName(ucasSubject));
        #     }

        #     // Does the subject list mention a subject we are happy to translate if the course title contains a mention?
        #     foreach(var ucasSubject in ucasSubjects.Intersect(ucasNeedsMentionInTitle.Keys))
        #     {
        #         if (ucasNeedsMentionInTitle[ucasSubject].IsMatch(courseTitle))
        #         {
        #             secondarySubjects.Add(MapToSubjectName(ucasSubject));
        #         }
        #     }

        #     // Does the subject list mention english, and it's mentioned in the title (or it's the only subject we know for this course)?
        #     if (ucasSubjects.Intersect(ucasEnglish).Any())
        #     {
        #         if (!secondarySubjects.Any() || courseTitle.IndexOf("english") > -1)
        #         {
        #             secondarySubjects.Add("English");
        #         }
        #     }

        #     // if nothing else yet, try welsh
        #     if (!secondarySubjects.Any() && ucasSubjects.Intersect(ucasMflWelsh).Any())
        #     {
        #         secondarySubjects.Add("Welsh");
        #     }

        #     return secondarySubjects;
        # }

        # private string MapToSubjectName(string ucasSubject)
        # {
        #     // rename if desired
        #     var res = ucasRename.TryGetValue(ucasSubject, out string mappedSubject) ? mappedSubject : ucasSubject;

        #     // capitalise
        #     res = res.Substring(0,1).ToUpper() + res.Substring(1).ToLower();

        #     // ensure English is always correctly cased
        #     return res.Replace("english", "English");
        # }
end

class FamilyTree
    attr_accessor :family_members

    @@num_family_members = 0
    FATHER, MOTHER, COUPLE, CHILDREN = "Father", "Mother", "Couple", "Children"
    
    def initialize
        @family_members = []
    end
    
    def is_member(id)
        @family_members.each do |member|
            return true if member.id == id
        end
        return false
    end

    def is_root(id)
        if is_member(id)
            @family_members.each do |member|
                return true if member.id == id and member.father_id == nil and member.mother_id == nil
            end
            return false
        end
    end

    def add_member(id:, name:, sex:, father_id:nil, mother_id:nil, couple_id:nil)
        unless is_member(id)
            @family_members << Member.new(id, name, sex, father_id, mother_id, couple_id)
            @@num_family_members+=1
        else
            puts("ID: #{id} already exists ..")
        end
    end

    def get_member_by_id(id)
        @family_members.each do |member|
            return member if member.id == id
        end
        nil
    end
    
    def count_members
        puts @@num_family_members
    end

    def show_family_tree
        @family_members.each do |member|
            puts member.get_data
        end
    end
    
    def get_relevant(id, relation)
        if is_member(id)
            @family_members.each do |member|
                if member.id == id
                    case relation
                        when FATHER then
                            father = get_member_by_id(member.father_id)
                            unless father
                                return nil
                            else
                                return father.get_data
                            end
                        when MOTHER then
                            mother = get_member_by_id(member.mother_id)
                            unless mother
                                return nil
                            else
                                return mother.get_data
                            end
                        when COUPLE then
                            couple = get_member_by_id(member.couple_id)
                            unless couple
                                return nil
                            else
                                return couple.get_data
                            end
                        when CHILDREN then
                            @children = []
                            @family_members.each do |member|
                                @children << member.get_data if member.father_id == id or member.mother_id == id
                            end
                            return @children
                    end
                end
            end
            nil
        else
            puts("ID: #{id} not a member ..")
        end
    end

    def get_grandfather(id)
        @level = 0
        @grands = []
        if is_member(id) and not is_root(id)
            @family_members.each do |member|
                if member.id == id
                    parents = [get_relevant(id, FATHER), get_relevant(id, MOTHER)]
                    parents.each do |parent|
                        g_father = get_relevant(parent['id'], FATHER)
                        @grands << g_father if g_father !=nil
                            
                    end
                    return @grands
                end
            end
        else
            puts("ID: #{id} not a member ..")
        end
    end

    def get_cousins(id)
        if is_member(id)
            @parents, @cousins = [], []
            @dad_id = get_relevant(id, FATHER)
            @mom_id = get_relevant(id, MOTHER)
            grandfather = get_grandfather(id)

            @family_members.each do |member|
                if member.father_id == grandfather[0]["id"]
                    @parents << member.get_data
                    @couple = get_relevant(member.id, COUPLE)
                    @parents << @couple if @couple 
                end
            end
            
            @parents.each do |parent|
                unless @dad_id["id"] == parent['id'] or @mom_id["id"] == parent['id']
                    k = get_relevant(parent["id"], CHILDREN)
                    @cousins << k unless @cousins .include? k
                end
            end
            return @cousins
        else
            puts("ID: #{id} not a member ..")
        end
    end
end

class Member
    attr_reader :id, :data, :sex
    attr_accessor :father_id, :mother_id, :couple_id

    def initialize(id, name, sex, father_id, mother_id, couple_id)
        @id, @name, @sex = id, name, sex
        @father_id, @mother_id, @couple_id = father_id, mother_id, couple_id
    end

    def get_name
        return @name
    end

    def get_data
        return{
            "id"=>@id,
            "name"=>@name,
            "sex"=>@sex,
            "father_id"=>@father_id,
            "mother_id"=>@mother_id,
            "couple_id"=>@couple_id
        }
    end
end

# Testing ...

def test_func
    tree = FamilyTree.new
    tree.add_member(id:1, name:"Ronnel Penrose", sex:"M", couple_id:2)
    tree.add_member(id:2, name:"Elaena Targaryen", sex:"F", couple_id:1)
    tree.add_member(id:3, name:"Robin Penrose", sex:"M", father_id:1, mother_id:2, couple_id:4)
    tree.add_member(id:4, name:"Perra Barathean", sex:"F", couple_id:3)
    tree.add_member(id:5, name:"Alysanne Penrose", sex:"F", father_id:3, mother_id:4, couple_id:6)
    tree.add_member(id:6, name:"Ormund Tarth", sex:"M", couple_id:5)
    tree.add_member(id:7, name:"Argella Swyert", sex:"F", couple_id:8)
    tree.add_member(id:8, name:"Robb Penrose", sex:"M", father_id:3, mother_id:4, couple_id:7)
    tree.add_member(id:9, name:"Rhae Targaryen", sex:"F", couple_id:10)
    tree.add_member(id:10, name:"Boros Tarth", sex:"M", father_id:6, mother_id:5, couple_id:9)
    tree.add_member(id:11, name:"Ravella Tarth", sex:"F", father_id:6, mother_id:5, couple_id:12)
    tree.add_member(id:12, name:"Robert Penrose", sex:"M", father_id:8, mother_id:7, couple_id:11)

    tree.count_members
    puts("\n")
    tree.show_family_tree
    puts("\n")
    puts "cousins of #{tree.get_member_by_id(12).get_data["name"]} are: "
    tree.get_cousins(12)[0].each do |person|
        p person["name"]
    end

end

test_func()
